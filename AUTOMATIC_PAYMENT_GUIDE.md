# Automatic Payment Verification Implementation Guide

## Overview
This guide shows how to integrate **1dokan.shop** payment gateway for automatic bKash and bank deposit verification in your BDPayX system.

## How 1dokan.shop Works

1. **Mobile App on Device**: They install a mobile app on an Android device that monitors incoming payments
2. **Real-time Detection**: When payment arrives (bKash/Nagad/Bank), the app detects it instantly
3. **API Notification**: Their system sends webhook/API callback to your server
4. **Auto-verification**: Your system automatically verifies and credits the user's wallet

## Implementation Steps

### Step 1: Get API Credentials from 1dokan.shop

You need:
- `API-KEY`: Your API key
- `SECRET-KEY`: Your secret key  
- `BRAND-KEY`: Your brand key

### Step 2: Add Environment Variables

Add to your `.env` file:
```env
DOKAN_API_KEY=your_api_key_here
DOKAN_SECRET_KEY=your_secret_key_here
DOKAN_BRAND_KEY=your_brand_key_here
DOKAN_API_URL=https://pay.1dokan.shop/api/payment
```

### Step 3: Install Required Package

```bash
npm install axios
```

### Step 4: Create Payment Service

Create `backend/src/services/dokanPayment.js`:

```javascript
const axios = require('axios');

class DokanPaymentService {
  constructor() {
    this.apiUrl = process.env.DOKAN_API_URL;
    this.apiKey = process.env.DOKAN_API_KEY;
    this.secretKey = process.env.DOKAN_SECRET_KEY;
    this.brandKey = process.env.DOKAN_BRAND_KEY;
  }

  getHeaders() {
    return {
      'API-KEY': this.apiKey,
      'SECRET-KEY': this.secretKey,
      'BRAND-KEY': this.brandKey,
      'Content-Type': 'application/json'
    };
  }

  async createPayment(customerName, customerEmail, amount, metadata = {}) {
    try {
      const response = await axios.post(
        `${this.apiUrl}/create`,
        {
          cus_name: customerName,
          cus_email: customerEmail,
          amount: amount.toString(),
          success_url: `${process.env.APP_URL}/api/wallet/payment-success`,
          cancel_url: `${process.env.APP_URL}/api/wallet/payment-cancel`,
          metadata: metadata
        },
        { headers: this.getHeaders() }
      );

      return response.data;
    } catch (error) {
      throw new Error(`Payment creation failed: ${error.message}`);
    }
  }

  async verifyPayment(transactionId) {
    try {
      const response = await axios.post(
        `${this.apiUrl}/verify`,
        { transaction_id: transactionId },
        { headers: this.getHeaders() }
      );

      return response.data;
    } catch (error) {
      throw new Error(`Payment verification failed: ${error.message}`);
    }
  }
}

module.exports = new DokanPaymentService();
```

### Step 5: Update Wallet Routes

Update `backend/src/routes/wallet.js` to add automatic payment:

```javascript
const dokanPayment = require('../services/dokanPayment');

// Create automatic deposit (new route)
router.post('/deposit-auto', authMiddleware, async (req, res) => {
  try {
    const { amount } = req.body;

    if (!amount || amount < 100) {
      return res.status(400).json({ error: 'Minimum deposit is ৳100' });
    }

    // Get user details
    const userResult = await pool.query(
      'SELECT full_name, email, phone FROM users WHERE id = $1',
      [req.userId]
    );

    const user = userResult.rows[0];

    // Create payment with 1dokan.shop
    const paymentData = await dokanPayment.createPayment(
      user.full_name,
      user.email,
      amount,
      {
        user_id: req.userId,
        phone: user.phone,
        deposit_type: 'wallet'
      }
    );

    if (!paymentData.status) {
      return res.status(400).json({ error: paymentData.message });
    }

    // Save pending deposit
    const depositRef = `DEP${Date.now()}${Math.floor(Math.random() * 1000)}`;
    
    await pool.query(
      `INSERT INTO wallet_deposits (user_id, deposit_ref, amount, payment_method, payment_details, status, transaction_id) 
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [
        req.userId,
        depositRef,
        amount,
        'auto_payment',
        JSON.stringify({ payment_url: paymentData.payment_url }),
        'pending',
        null // Will be updated on callback
      ]
    );

    res.json({
      success: true,
      payment_url: paymentData.payment_url,
      message: 'Complete payment on the payment page'
    });

  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Payment success callback
router.get('/payment-success', async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    const { transactionId, paymentMethod, paymentAmount, status } = req.query;

    if (status !== 'success') {
      await client.query('ROLLBACK');
      return res.redirect(`${process.env.FRONTEND_URL}/wallet?payment=failed`);
    }

    // Verify payment with 1dokan.shop
    const verification = await dokanPayment.verifyPayment(transactionId);

    if (verification.status !== 'COMPLETED') {
      await client.query('ROLLBACK');
      return res.redirect(`${process.env.FRONTEND_URL}/wallet?payment=pending`);
    }

    // Get user from metadata
    const userId = verification.metadata.user_id;
    const amount = parseFloat(verification.amount);

    // Check if already processed
    const existingCheck = await client.query(
      'SELECT id FROM wallet_deposits WHERE transaction_id = $1',
      [transactionId]
    );

    if (existingCheck.rows.length > 0) {
      await client.query('ROLLBACK');
      return res.redirect(`${process.env.FRONTEND_URL}/wallet?payment=already_processed`);
    }

    // Get current balance
    const userResult = await client.query(
      'SELECT bdt_balance FROM users WHERE id = $1',
      [userId]
    );

    const currentBalance = parseFloat(userResult.rows[0].bdt_balance || 0);
    const newBalance = currentBalance + amount;

    // Update user balance
    await client.query(
      'UPDATE users SET bdt_balance = $1 WHERE id = $2',
      [newBalance, userId]
    );

    // Update deposit record
    await client.query(
      `UPDATE wallet_deposits 
       SET status = $1, transaction_id = $2, payment_method = $3, updated_at = CURRENT_TIMESTAMP 
       WHERE user_id = $4 AND status = $5 AND amount = $6`,
      ['approved', transactionId, paymentMethod, userId, 'pending', amount]
    );

    // Log transaction
    await client.query(
      `INSERT INTO wallet_transactions (user_id, transaction_type, amount, currency, balance_before, balance_after, reference_id, reference_type, description) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [userId, 'deposit', amount, 'BDT', currentBalance, newBalance, transactionId, 'auto_payment', `Auto deposit via ${paymentMethod}`]
    );

    // Create notification
    await client.query(
      'INSERT INTO notifications (user_id, title, message, type) VALUES ($1, $2, $3, $4)',
      [userId, 'Deposit Successful', `৳${amount} has been added to your wallet via ${paymentMethod}`, 'deposit']
    );

    await client.query('COMMIT');
    res.redirect(`${process.env.FRONTEND_URL}/wallet?payment=success&amount=${amount}`);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Payment success error:', error);
    res.redirect(`${process.env.FRONTEND_URL}/wallet?payment=error`);
  } finally {
    client.release();
  }
});

// Payment cancel callback
router.get('/payment-cancel', async (req, res) => {
  res.redirect(`${process.env.FRONTEND_URL}/wallet?payment=cancelled`);
});
```

### Step 6: Update Database Schema

Add transaction_id column to wallet_deposits:

```sql
ALTER TABLE wallet_deposits 
ADD COLUMN IF NOT EXISTS transaction_id VARCHAR(255) UNIQUE;

CREATE INDEX IF NOT EXISTS idx_wallet_deposits_transaction_id 
ON wallet_deposits(transaction_id);
```

### Step 7: Frontend Integration

Update your Flutter app or web frontend to use the new endpoint:

```javascript
// In your deposit component
async function initiateAutoDeposit(amount) {
  try {
    const response = await fetch('/api/wallet/deposit-auto', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ amount })
    });

    const data = await response.json();

    if (data.success) {
      // Redirect user to payment page
      window.location.href = data.payment_url;
    }
  } catch (error) {
    console.error('Deposit error:', error);
  }
}
```

## Benefits

✅ **Instant Verification**: No manual approval needed
✅ **Multiple Methods**: Supports bKash, Nagad, Rocket, Bank transfers
✅ **Real-time**: Payment detected and credited within seconds
✅ **No Manual Work**: Completely automated process
✅ **Secure**: Uses API verification to prevent fraud

## Cost

1dokan.shop charges a small fee per transaction. Contact them for pricing.

## Testing

1. Use their sandbox/test environment first
2. Make small test deposits
3. Verify the callback URLs work correctly
4. Check database updates happen properly

## Important Notes

- Keep your API keys secure in environment variables
- Always verify payments server-side (never trust client data)
- Handle edge cases (duplicate payments, failed verifications)
- Log all payment activities for audit trail
- Set up proper error notifications

## Support

For 1dokan.shop support:
- Website: https://1dokan.shop
- Documentation: https://pay.1dokan.shop/docs

---

**Ready to implement?** Start with Step 1 and work through each step carefully.

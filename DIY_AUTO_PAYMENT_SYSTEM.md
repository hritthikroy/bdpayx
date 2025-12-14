# DIY Automatic Payment Verification System

## Overview
Build your own automatic payment gateway by creating an Android app that monitors bKash/Nagad SMS and sends notifications to your server.

## System Architecture

```
[Customer] → [bKash/Nagad Payment] → [SMS to Your Phone] → [Android App] → [Your Server API] → [Auto Credit Wallet]
```

## Components Needed

1. **Android App** - Monitors SMS and sends to server
2. **Backend API** - Receives payment notifications
3. **Database** - Stores payment mappings
4. **Frontend** - Shows payment instructions

## Part 1: Backend API Setup

### Step 1: Create Payment Monitoring Service


Create `backend/src/services/smsPaymentMonitor.js`:

```javascript
const crypto = require('crypto');

class SMSPaymentMonitor {
  // Generate unique reference for each deposit request
  generatePaymentReference(userId, amount) {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000);
    return `PAY${userId}${timestamp}${random}`;
  }

  // Parse bKash SMS format
  parseBkashSMS(smsBody) {
    // Example: "You have received Tk 500.00 from 01712345678 on 15/12/2024. TrxID: ABC123XYZ"
    const amountMatch = smsBody.match(/Tk\s*([\d,]+\.?\d*)/i);
    const senderMatch = smsBody.match(/from\s*(\d{11})/i);
    const trxIdMatch = smsBody.match(/TrxID[:\s]*([A-Z0-9]+)/i);
    
    return {
      amount: amountMatch ? parseFloat(amountMatch[1].replace(',', '')) : null,
      sender: senderMatch ? senderMatch[1] : null,
      trxId: trxIdMatch ? trxIdMatch[1] : null,
      method: 'bkash'
    };
  }

  // Parse Nagad SMS format
  parseNagadSMS(smsBody) {
    // Example: "Cash In Tk 500.00 from 01712345678. TxnID: ABC123. Balance: Tk 1000"
    const amountMatch = smsBody.match(/Tk\s*([\d,]+\.?\d*)/i);
    const senderMatch = smsBody.match(/from\s*(\d{11})/i);
    const trxIdMatch = smsBody.match(/TxnID[:\s]*([A-Z0-9]+)/i);
    
    return {
      amount: amountMatch ? parseFloat(amountMatch[1].replace(',', '')) : null,
      sender: senderMatch ? senderMatch[1] : null,
      trxId: trxIdMatch ? trxIdMatch[1] : null,
      method: 'nagad'
    };
  }

  // Determine payment method from SMS sender
  detectPaymentMethod(smsSender) {
    if (smsSender.includes('bKash') || smsSender.includes('16247')) {
      return 'bkash';
    } else if (smsSender.includes('Nagad') || smsSender.includes('16167')) {
      return 'nagad';
    } else if (smsSender.includes('Rocket')) {
      return 'rocket';
    }
    return 'unknown';
  }
}

module.exports = new SMSPaymentMonitor();
```


### Step 2: Create SMS Webhook Route

Create `backend/src/routes/smsWebhook.js`:

```javascript
const express = require('express');
const pool = require('../config/database');
const smsMonitor = require('../services/smsPaymentMonitor');

const router = express.Router();

// Security: API key for Android app
const SMS_WEBHOOK_KEY = process.env.SMS_WEBHOOK_KEY || 'your-secret-key-here';

// Middleware to verify webhook requests
const verifyWebhook = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey !== SMS_WEBHOOK_KEY) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
};

// Receive SMS from Android app
router.post('/sms-received', verifyWebhook, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    const { sender, body, timestamp } = req.body;

    // Detect payment method
    const method = smsMonitor.detectPaymentMethod(sender);
    
    if (method === 'unknown') {
      return res.json({ success: false, message: 'Not a payment SMS' });
    }

    // Parse SMS based on method
    let paymentData;
    if (method === 'bkash') {
      paymentData = smsMonitor.parseBkashSMS(body);
    } else if (method === 'nagad') {
      paymentData = smsMonitor.parseNagadSMS(body);
    }

    if (!paymentData.amount || !paymentData.trxId) {
      return res.json({ success: false, message: 'Could not parse payment details' });
    }

    // Check if transaction already processed
    const existingCheck = await client.query(
      'SELECT id FROM wallet_deposits WHERE transaction_id = $1',
      [paymentData.trxId]
    );

    if (existingCheck.rows.length > 0) {
      await client.query('ROLLBACK');
      return res.json({ success: false, message: 'Transaction already processed' });
    }

    // Find matching pending deposit (within ±10 Tk tolerance)
    const pendingDeposit = await client.query(
      `SELECT * FROM wallet_deposits 
       WHERE status = 'pending' 
       AND payment_method = $1
       AND ABS(amount - $2) <= 10
       AND created_at > NOW() - INTERVAL '30 minutes'
       ORDER BY created_at DESC
       LIMIT 1`,
      [method, paymentData.amount]
    );

    if (pendingDeposit.rows.length === 0) {
      // Log unmatched payment for manual review
      await client.query(
        `INSERT INTO unmatched_payments (method, amount, sender, trx_id, sms_body, sms_timestamp)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [method, paymentData.amount, paymentData.sender, paymentData.trxId, body, timestamp]
      );
      
      await client.query('COMMIT');
      return res.json({ success: false, message: 'No matching deposit found' });
    }

    const deposit = pendingDeposit.rows[0];

    // Get user balance
    const userResult = await client.query(
      'SELECT bdt_balance FROM users WHERE id = $1',
      [deposit.user_id]
    );

    const currentBalance = parseFloat(userResult.rows[0].bdt_balance || 0);
    const newBalance = currentBalance + parseFloat(deposit.amount);

    // Update user balance
    await client.query(
      'UPDATE users SET bdt_balance = $1 WHERE id = $2',
      [newBalance, deposit.user_id]
    );

    // Update deposit status
    await client.query(
      `UPDATE wallet_deposits 
       SET status = $1, transaction_id = $2, updated_at = CURRENT_TIMESTAMP,
           payment_details = $3
       WHERE id = $4`,
      ['approved', paymentData.trxId, JSON.stringify(paymentData), deposit.id]
    );

    // Log transaction
    await client.query(
      `INSERT INTO wallet_transactions 
       (user_id, transaction_type, amount, currency, balance_before, balance_after, 
        reference_id, reference_type, description) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        deposit.user_id, 'deposit', deposit.amount, 'BDT', 
        currentBalance, newBalance, deposit.id, 'auto_sms', 
        `Auto deposit via ${method} - ${paymentData.trxId}`
      ]
    );

    // Create notification
    await client.query(
      'INSERT INTO notifications (user_id, title, message, type) VALUES ($1, $2, $3, $4)',
      [
        deposit.user_id, 
        'Deposit Approved', 
        `৳${deposit.amount} has been automatically added to your wallet`, 
        'deposit'
      ]
    );

    await client.query('COMMIT');
    
    res.json({ 
      success: true, 
      message: 'Payment processed successfully',
      userId: deposit.user_id,
      amount: deposit.amount
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('SMS webhook error:', error);
    res.status(500).json({ error: error.message });
  } finally {
    client.release();
  }
});

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

module.exports = router;
```


### Step 3: Update Database Schema

```sql
-- Add transaction_id to wallet_deposits
ALTER TABLE wallet_deposits 
ADD COLUMN IF NOT EXISTS transaction_id VARCHAR(255) UNIQUE;

-- Create unmatched payments table
CREATE TABLE IF NOT EXISTS unmatched_payments (
  id SERIAL PRIMARY KEY,
  method VARCHAR(50) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  sender VARCHAR(20),
  trx_id VARCHAR(255) UNIQUE,
  sms_body TEXT,
  sms_timestamp TIMESTAMP,
  matched BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_wallet_deposits_transaction_id ON wallet_deposits(transaction_id);
CREATE INDEX IF NOT EXISTS idx_unmatched_payments_trx_id ON unmatched_payments(trx_id);
CREATE INDEX IF NOT EXISTS idx_wallet_deposits_pending ON wallet_deposits(status, payment_method, created_at);
```

### Step 4: Register Route in Server

Update `backend/src/server.js`:

```javascript
const smsWebhookRoutes = require('./routes/smsWebhook');

// Add this line with other routes
app.use('/api/sms-webhook', smsWebhookRoutes);
```

### Step 5: Add Environment Variables

Add to `.env`:

```env
SMS_WEBHOOK_KEY=your-super-secret-key-change-this
```

## Part 2: Android App Development

### Create Android App Structure

Create a new Android Studio project with these files:


## Part 3: Implementation Steps

### Backend Setup

1. **Create the service file:**
```bash
# Already created: backend/src/services/smsPaymentMonitor.js
```

2. **Create the webhook route:**
```bash
# Already created: backend/src/routes/smsWebhook.js
```

3. **Run database migrations:**
```bash
node -e "
const pool = require('./backend/src/config/database');
const sql = \`
ALTER TABLE wallet_deposits ADD COLUMN IF NOT EXISTS transaction_id VARCHAR(255) UNIQUE;

CREATE TABLE IF NOT EXISTS unmatched_payments (
  id SERIAL PRIMARY KEY,
  method VARCHAR(50) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  sender VARCHAR(20),
  trx_id VARCHAR(255) UNIQUE,
  sms_body TEXT,
  sms_timestamp TIMESTAMP,
  matched BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wallet_deposits_transaction_id ON wallet_deposits(transaction_id);
CREATE INDEX IF NOT EXISTS idx_unmatched_payments_trx_id ON unmatched_payments(trx_id);
\`;
pool.query(sql).then(() => console.log('Done')).catch(console.error);
"
```

4. **Update your .env file:**
```env
SMS_WEBHOOK_KEY=your-super-secret-key-12345
```

5. **Register the route in server.js**

### Android App Setup

1. **Open Android Studio**
2. **Create new project** (Empty Activity)
3. **Copy the files** from `android-sms-monitor/` folder
4. **Build APK**
5. **Install on Android device**

### Configuration

1. **Install Android app** on a device with SIM card
2. **Open the app** and configure:
   - Server URL: `https://yourdomain.com`
   - API Key: Same as `SMS_WEBHOOK_KEY` in .env
3. **Grant SMS permissions**
4. **Keep app running** in background

## Part 4: Testing

### Test the System

1. **Create a test deposit:**
```bash
curl -X POST http://localhost:3000/api/wallet/deposit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100,
    "payment_method": "bkash",
    "payment_details": {
      "account": "01712345678"
    }
  }'
```

2. **Send test payment** to your bKash number (৳100)

3. **SMS arrives** → Android app detects it

4. **App sends to server** → Server matches and credits wallet

5. **Check user balance** - should be updated automatically!

## Part 5: Frontend Integration

Update your deposit UI to show payment instructions:

```javascript
// When user initiates deposit
async function createDeposit(amount, method) {
  const response = await fetch('/api/wallet/deposit', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      amount,
      payment_method: method,
      payment_details: { account: getPaymentAccount(method) }
    })
  });

  const data = await response.json();

  // Show payment instructions
  showPaymentInstructions({
    method: method,
    amount: amount,
    account: getPaymentAccount(method),
    reference: data.deposit_ref
  });
}

function getPaymentAccount(method) {
  const accounts = {
    'bkash': '01712345678',
    'nagad': '01712345678',
    'rocket': '01712345678'
  };
  return accounts[method];
}

function showPaymentInstructions(data) {
  alert(`
    Send ৳${data.amount} to:
    ${data.method.toUpperCase()}: ${data.account}
    
    Your payment will be automatically verified within seconds!
  `);
}
```

## Security Considerations

1. **API Key Security**: Use strong, random API keys
2. **HTTPS Only**: Always use HTTPS for webhook endpoint
3. **Rate Limiting**: Add rate limiting to webhook endpoint
4. **IP Whitelist**: Optionally whitelist your Android device IP
5. **Duplicate Prevention**: Check transaction IDs to prevent double-crediting
6. **Amount Tolerance**: Use ±10 Tk tolerance for matching
7. **Time Window**: Only match deposits within 30 minutes

## Advantages

✅ **No Third-party Fees**: Completely free, no transaction fees
✅ **Full Control**: You own the entire system
✅ **Instant**: Verification happens in seconds
✅ **Multiple Methods**: Works with bKash, Nagad, Rocket
✅ **Customizable**: Modify SMS parsing for your needs

## Disadvantages

⚠️ **Requires Android Device**: Need a dedicated phone
⚠️ **SMS Dependency**: Relies on SMS format (can change)
⚠️ **Manual Setup**: More complex than using third-party API
⚠️ **Maintenance**: You maintain the Android app

## Troubleshooting

### SMS not detected
- Check SMS permissions granted
- Verify SMS sender matches patterns
- Check Android app logs

### Payment not matched
- Check amount tolerance (±10 Tk)
- Verify time window (30 minutes)
- Check `unmatched_payments` table

### Server not receiving webhook
- Verify server URL in app
- Check API key matches
- Ensure HTTPS certificate valid
- Check firewall/network settings

## Production Checklist

- [ ] Android app installed on dedicated device
- [ ] Device has reliable power supply
- [ ] Device has stable internet connection
- [ ] SMS permissions granted
- [ ] Server URL configured correctly
- [ ] API key set and secure
- [ ] Database migrations run
- [ ] Webhook endpoint tested
- [ ] SSL certificate valid
- [ ] Monitoring/logging enabled
- [ ] Backup device ready (optional)

## Next Steps

1. Set up the backend routes and services
2. Build and install the Android app
3. Test with small amounts first
4. Monitor the `unmatched_payments` table
5. Adjust SMS parsing patterns as needed
6. Add admin dashboard to view unmatched payments

---

**Ready to implement?** Start with the backend setup, then build the Android app!

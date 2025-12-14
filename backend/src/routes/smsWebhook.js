const express = require('express');
const pool = require('../config/database');
const smsMonitor = require('../services/smsPaymentMonitor');

const router = express.Router();

// Security: API key for Android app
const SMS_WEBHOOK_KEY = process.env.SMS_WEBHOOK_KEY || 'change-this-secret-key';

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

    console.log('SMS received:', { sender, body });

    // Detect payment method
    const method = smsMonitor.detectPaymentMethod(sender);
    
    if (method === 'unknown') {
      await client.query('ROLLBACK');
      return res.json({ success: false, message: 'Not a payment SMS' });
    }

    // Parse SMS based on method
    const paymentData = smsMonitor.parseSMS(method, body);

    if (!paymentData || !paymentData.amount || !paymentData.trxId) {
      await client.query('ROLLBACK');
      return res.json({ success: false, message: 'Could not parse payment details' });
    }

    console.log('Parsed payment:', paymentData);

    // Check if transaction already processed
    const existingCheck = await client.query(
      'SELECT id FROM wallet_deposits WHERE transaction_id = $1',
      [paymentData.trxId]
    );

    if (existingCheck.rows.length > 0) {
      await client.query('ROLLBACK');
      return res.json({ success: false, message: 'Transaction already processed' });
    }

    // Find matching pending deposit (within ±10 Tk tolerance, last 30 minutes)
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
        [method, paymentData.amount, paymentData.sender, paymentData.trxId, body, new Date(timestamp)]
      );
      
      await client.query('COMMIT');
      console.log('No matching deposit found - saved to unmatched_payments');
      return res.json({ success: false, message: 'No matching deposit found' });
    }

    const deposit = pendingDeposit.rows[0];

    console.log('Matched deposit:', deposit.id);

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
        'Deposit Approved ✓', 
        `৳${deposit.amount} has been automatically added to your wallet via ${method}`, 
        'deposit'
      ]
    );

    await client.query('COMMIT');
    
    console.log('Payment processed successfully:', {
      userId: deposit.user_id,
      amount: deposit.amount,
      method: method
    });

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
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    service: 'SMS Webhook'
  });
});

// Get unmatched payments (admin only)
router.get('/unmatched', verifyWebhook, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM unmatched_payments 
       WHERE matched = false 
       ORDER BY created_at DESC 
       LIMIT 50`
    );
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

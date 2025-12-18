const express = require('express');
const multer = require('multer');
const pool = require('../config/database');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/payment-proofs/');
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({ storage });

// Create transaction (exchange from wallet balance)
router.post('/', authMiddleware, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { from_amount, to_amount, exchange_rate } = req.body;
    
    // Check user's BDT balance
    const userResult = await client.query(
      'SELECT bdt_balance FROM users WHERE id = $1',
      [req.userId]
    );
    
    const currentBalance = parseFloat(userResult.rows[0].bdt_balance || 0);
    
    if (currentBalance < from_amount) {
      await client.query('ROLLBACK');
      return res.status(400).json({ 
        error: `Insufficient balance. You have ৳${currentBalance.toFixed(2)} but trying to exchange ৳${from_amount}` 
      });
    }
    
    // Check for pending transactions
    const pendingCheck = await client.query(
      'SELECT id FROM transactions WHERE user_id = $1 AND status IN ($2, $3)',
      [req.userId, 'pending', 'under_review']
    );
    
    if (pendingCheck.rows.length > 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({ 
        error: 'You already have a pending exchange. Please wait for completion or cancel it first.' 
      });
    }
    
    const transactionRef = `TXN${Date.now()}${Math.floor(Math.random() * 1000)}`;
    
    // Deduct from BDT balance
    const newBdtBalance = currentBalance - from_amount;
    await client.query(
      'UPDATE users SET bdt_balance = $1 WHERE id = $2',
      [newBdtBalance, req.userId]
    );
    
    // Create transaction
    const result = await client.query(
      `INSERT INTO transactions (user_id, transaction_ref, from_currency, to_currency, 
       from_amount, to_amount, exchange_rate, status) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [req.userId, transactionRef, 'BDT', 'INR', from_amount, to_amount, exchange_rate, 'processing']
    );
    
    // Log wallet transaction
    await client.query(
      `INSERT INTO wallet_transactions (user_id, transaction_type, amount, currency, balance_before, balance_after, reference_id, reference_type, description) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [req.userId, 'exchange_debit', from_amount, 'BDT', currentBalance, newBdtBalance, result.rows[0].id, 'exchange', `Exchange ${from_amount} BDT to ${to_amount} INR`]
    );
    
    await client.query('COMMIT');
    res.json(result.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(400).json({ error: error.message });
  } finally {
    client.release();
  }
});

// Upload payment proof
router.post('/:id/upload-proof', authMiddleware, upload.single('proof'), async (req, res) => {
  try {
    const { id } = req.params;
    const proofUrl = `/uploads/payment-proofs/${req.file.filename}`;
    
    const result = await pool.query(
      'UPDATE transactions SET payment_proof_url = $1, status = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 AND user_id = $4 RETURNING *',
      [proofUrl, 'under_review', id, req.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get user transactions
router.get('/', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC',
      [req.userId]
    );
    res.json(result.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get transaction by ID
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM transactions WHERE id = $1 AND user_id = $2',
      [req.params.id, req.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Cancel transaction
router.post('/:id/cancel', authMiddleware, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { id } = req.params;
    
    // Get transaction
    const txResult = await client.query(
      'SELECT * FROM transactions WHERE id = $1 AND user_id = $2 AND status IN ($3, $4)',
      [id, req.userId, 'pending', 'processing']
    );
    
    if (txResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Transaction not found or cannot be cancelled' });
    }
    
    const transaction = txResult.rows[0];
    
    // Refund BDT balance
    await client.query(
      'UPDATE users SET bdt_balance = bdt_balance + $1 WHERE id = $2',
      [transaction.from_amount, req.userId]
    );
    
    // Update transaction status
    await client.query(
      'UPDATE transactions SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      ['cancelled', id]
    );
    
    await client.query('COMMIT');
    res.json({ success: true, message: 'Transaction cancelled and balance refunded' });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(400).json({ error: error.message });
  } finally {
    client.release();
  }
});

module.exports = router;

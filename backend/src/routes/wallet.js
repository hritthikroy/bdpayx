const express = require('express');
const multer = require('multer');
const pool = require('../config/database');
const supabase = require('../config/supabase');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Configure multer for memory storage (Vercel compatible)
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// Get wallet balance
router.get('/balance', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT bdt_balance, balance as inr_balance FROM users WHERE id = $1',
      [req.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json({
      bdt_balance: parseFloat(result.rows[0].bdt_balance || 0),
      inr_balance: parseFloat(result.rows[0].inr_balance || 0)
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get deposit payment methods
router.get('/deposit-methods', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM payment_instructions WHERE payment_method IN ('bank_transfer', 'bkash') AND is_active = true"
    );
    res.json(result.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Create deposit request
router.post('/deposit', authMiddleware, async (req, res) => {
  try {
    const { amount, payment_method, payment_details } = req.body;
    
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Invalid amount' });
    }
    
    // Check for existing pending deposit
    const pendingCheck = await pool.query(
      'SELECT id FROM wallet_deposits WHERE user_id = $1 AND status IN ($2, $3)',
      [req.userId, 'pending', 'under_review']
    );
    
    if (pendingCheck.rows.length > 0) {
      return res.status(400).json({ 
        error: 'You already have a pending deposit. Please wait for approval or cancel it first.' 
      });
    }
    
    const depositRef = `DEP${Date.now()}${Math.floor(Math.random() * 1000)}`;
    
    const result = await pool.query(
      `INSERT INTO wallet_deposits (user_id, deposit_ref, amount, payment_method, payment_details, status) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [req.userId, depositRef, amount, payment_method, JSON.stringify(payment_details), 'pending']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Upload deposit proof (Supabase Storage)
router.post('/deposit/:id/upload-proof', authMiddleware, upload.single('proof'), async (req, res) => {
  try {
    const { id } = req.params;
    
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    
    // Upload to Supabase Storage
    const fileName = `deposit-proofs/${req.userId}/${Date.now()}-${req.file.originalname}`;
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('exchange-proofs')
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: false
      });
    
    if (uploadError) {
      console.error('Supabase upload error:', uploadError);
      return res.status(500).json({ error: 'Failed to upload file' });
    }
    
    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('exchange-proofs')
      .getPublicUrl(fileName);
    
    const result = await pool.query(
      'UPDATE wallet_deposits SET payment_proof_url = $1, status = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 AND user_id = $4 RETURNING *',
      [publicUrl, 'under_review', id, req.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Deposit not found' });
    }
    
    // Create notification
    await pool.query(
      'INSERT INTO notifications (user_id, title, message, type) VALUES ($1, $2, $3, $4)',
      [req.userId, 'Deposit Under Review', `Your deposit of ৳${result.rows[0].amount} is being reviewed`, 'deposit']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Upload proof error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Cancel deposit
router.post('/deposit/:id/cancel', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query(
      'UPDATE wallet_deposits SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 AND user_id = $3 AND status IN ($4, $5) RETURNING *',
      ['cancelled', id, req.userId, 'pending', 'under_review']
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Deposit not found or cannot be cancelled' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get deposit history
router.get('/deposits', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM wallet_deposits WHERE user_id = $1 ORDER BY created_at DESC',
      [req.userId]
    );
    res.json(result.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get wallet transaction history
router.get('/transactions', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM wallet_transactions WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50',
      [req.userId]
    );
    res.json(result.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Admin: Get pending deposits
router.get('/admin/deposits/pending', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT d.*, u.phone, u.full_name, u.email 
       FROM wallet_deposits d 
       JOIN users u ON d.user_id = u.id 
       WHERE d.status = 'under_review' 
       ORDER BY d.created_at DESC`
    );
    res.json(result.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Admin: Approve deposit
router.post('/admin/deposits/:id/approve', authMiddleware, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { id } = req.params;
    const { admin_notes } = req.body;
    
    // Get deposit details
    const depositResult = await client.query(
      'SELECT * FROM wallet_deposits WHERE id = $1',
      [id]
    );
    
    if (depositResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Deposit not found' });
    }
    
    const deposit = depositResult.rows[0];
    
    // Get current balance
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
      'UPDATE wallet_deposits SET status = $1, admin_notes = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3',
      ['approved', admin_notes, id]
    );
    
    // Create wallet transaction record
    await client.query(
      `INSERT INTO wallet_transactions (user_id, transaction_type, amount, currency, balance_before, balance_after, reference_id, reference_type, description) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [deposit.user_id, 'deposit', deposit.amount, 'BDT', currentBalance, newBalance, id, 'wallet_deposit', `Deposit via ${deposit.payment_method}`]
    );
    
    // Create notification
    await client.query(
      'INSERT INTO notifications (user_id, title, message, type) VALUES ($1, $2, $3, $4)',
      [deposit.user_id, 'Deposit Approved', `Your deposit of ৳${deposit.amount} has been approved and added to your wallet`, 'deposit']
    );
    
    await client.query('COMMIT');
    
    res.json({ success: true, message: 'Deposit approved', new_balance: newBalance });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(400).json({ error: error.message });
  } finally {
    client.release();
  }
});

// Admin: Reject deposit
router.post('/admin/deposits/:id/reject', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { admin_notes } = req.body;
    
    const result = await pool.query(
      'UPDATE wallet_deposits SET status = $1, admin_notes = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING *',
      ['rejected', admin_notes, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Deposit not found' });
    }
    
    // Create notification
    await pool.query(
      'INSERT INTO notifications (user_id, title, message, type) VALUES ($1, $2, $3, $4)',
      [result.rows[0].user_id, 'Deposit Rejected', `Your deposit of ৳${result.rows[0].amount} has been rejected. Reason: ${admin_notes}`, 'deposit']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;

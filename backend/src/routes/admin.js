const express = require('express');
const pool = require('../config/database');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

const router = express.Router();

// Get all pending transactions
router.get('/transactions/pending', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT t.*, u.phone, u.full_name, u.email 
       FROM transactions t 
       JOIN users u ON t.user_id = u.id 
       WHERE t.status = 'under_review' 
       ORDER BY t.created_at DESC`
    );
    res.json(result.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Approve transaction
router.post('/transactions/:id/approve', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { admin_notes } = req.body;
    
    const result = await pool.query(
      'UPDATE transactions SET status = $1, admin_notes = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING *',
      ['approved', admin_notes, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    
    // Create notification
    await pool.query(
      'INSERT INTO notifications (user_id, title, message, type) VALUES ($1, $2, $3, $4)',
      [result.rows[0].user_id, 'Transaction Approved', `Your transaction ${result.rows[0].transaction_ref} has been approved`, 'transaction']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Reject transaction
router.post('/transactions/:id/reject', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { admin_notes } = req.body;
    
    const result = await pool.query(
      'UPDATE transactions SET status = $1, admin_notes = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING *',
      ['rejected', admin_notes, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    
    // Create notification
    await pool.query(
      'INSERT INTO notifications (user_id, title, message, type) VALUES ($1, $2, $3, $4)',
      [result.rows[0].user_id, 'Transaction Rejected', `Your transaction ${result.rows[0].transaction_ref} has been rejected. Reason: ${admin_notes}`, 'transaction']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Update exchange rate
router.post('/exchange-rate', authMiddleware, adminMiddleware, async (req, res) => {
  try {
    const { base_rate } = req.body;
    
    const result = await pool.query(
      'UPDATE exchange_rates SET base_rate = $1, updated_at = CURRENT_TIMESTAMP, updated_by = $2 WHERE from_currency = $3 AND to_currency = $4 RETURNING *',
      [base_rate, req.userId, 'BDT', 'INR']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;

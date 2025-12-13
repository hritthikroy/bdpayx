const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Register
router.post('/register', async (req, res) => {
  try {
    const { phone, email, password, full_name } = req.body;
    
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const result = await pool.query(
      'INSERT INTO users (phone, email, password_hash, full_name) VALUES ($1, $2, $3, $4) RETURNING id, phone, email, full_name',
      [phone, email, hashedPassword, full_name]
    );
    
    const token = jwt.sign(
      { userId: result.rows[0].id, role: 'user' },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    res.json({ user: result.rows[0], token });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    
    const result = await pool.query('SELECT * FROM users WHERE phone = $1', [phone]);
    
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const user = result.rows[0];
    const isValid = await bcrypt.compare(password, user.password_hash);
    
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const token = jwt.sign(
      { userId: user.id, role: 'user' },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    delete user.password_hash;
    res.json({ user, token });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get profile
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, phone, email, full_name, kyc_status, balance, created_at FROM users WHERE id = $1',
      [req.userId]
    );
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;

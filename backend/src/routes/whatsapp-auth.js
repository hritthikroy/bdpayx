const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const whatsappService = require('../services/whatsapp');

// Send OTP via WhatsApp
router.post('/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ error: 'Phone number is required' });
    }

    // Validate phone number format
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    if (!phoneRegex.test(phone)) {
      return res.status(400).json({ error: 'Invalid phone number format' });
    }

    // Send OTP
    const result = await whatsappService.sendOTP(phone);

    res.json({
      success: true,
      message: 'OTP sent to your WhatsApp',
      ...result
    });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Verify OTP and login/register
router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({ error: 'Phone and OTP are required' });
    }

    // Verify OTP
    const verification = whatsappService.verifyOTP(phone, otp);

    if (!verification.success) {
      return res.status(400).json({ error: verification.message });
    }

    // Check if user exists
    let user = await pool.query(
      'SELECT * FROM users WHERE phone = $1',
      [phone]
    );

    // If user doesn't exist, create new user
    if (user.rows.length === 0) {
      const result = await pool.query(
        `INSERT INTO users (phone, full_name, kyc_status, balance) 
         VALUES ($1, $2, $3, $4) 
         RETURNING id, phone, full_name, email, kyc_status, balance`,
        [phone, 'User', 'pending', 0]
      );
      user = result;
    }

    const userData = user.rows[0];

    // Generate JWT token
    const token = jwt.sign(
      { 
        userId: userData.id, 
        phone: userData.phone 
      },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: userData.id,
        phone: userData.phone,
        fullName: userData.full_name,
        email: userData.email,
        kycStatus: userData.kyc_status,
        balance: parseFloat(userData.balance)
      }
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
});

// Resend OTP
router.post('/resend-otp', async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ error: 'Phone number is required' });
    }

    // Send new OTP
    const result = await whatsappService.sendOTP(phone);

    res.json({
      success: true,
      message: 'New OTP sent to your WhatsApp',
      ...result
    });
  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

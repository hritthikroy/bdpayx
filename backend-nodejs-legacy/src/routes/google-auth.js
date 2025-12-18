const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const { OAuth2Client } = require('google-auth-library');

// Initialize Google OAuth client
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Google Sign In
router.post('/google-login', async (req, res) => {
  try {
    const { idToken, email, displayName, photoUrl } = req.body;

    if (!idToken && !email) {
      return res.status(400).json({ error: 'ID token or email is required' });
    }

    let googleEmail = email;
    let googleName = displayName;

    // Verify Google ID token if provided
    if (idToken) {
      try {
        const ticket = await client.verifyIdToken({
          idToken: idToken,
          audience: process.env.GOOGLE_CLIENT_ID,
        });
        const payload = ticket.getPayload();
        googleEmail = payload.email;
        googleName = payload.name;
      } catch (verifyError) {
        console.log('Token verification failed, using provided data');
      }
    }

    if (!googleEmail) {
      return res.status(400).json({ error: 'Email is required' });
    }

    // Check if user exists
    let user = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [googleEmail]
    );

    // If user doesn't exist, create new user
    if (user.rows.length === 0) {
      // Generate a random password hash for Google users (they don't use password)
      const bcrypt = require('bcryptjs');
      const randomPassword = Math.random().toString(36).substring(2, 15);
      const passwordHash = await bcrypt.hash(randomPassword, 10);
      
      // Extract phone from email or use placeholder
      const phone = googleEmail.split('@')[0].replace(/[^0-9]/g, '');
      const userPhone = phone ? `+${phone}` : `+google${Date.now()}`;
      
      const result = await pool.query(
        `INSERT INTO users (email, phone, password_hash, full_name, kyc_status, balance) 
         VALUES ($1, $2, $3, $4, $5, $6) 
         RETURNING id, email, phone, full_name, kyc_status, balance`,
        [googleEmail, userPhone, passwordHash, googleName || 'User', 'pending', 0]
      );
      user = result;
    } else {
      // Update existing user's name if it changed
      if (googleName && googleName !== user.rows[0].full_name) {
        await pool.query(
          'UPDATE users SET full_name = $1 WHERE id = $2',
          [googleName, user.rows[0].id]
        );
        user.rows[0].full_name = googleName;
      }
    }

    const userData = user.rows[0];

    // Generate JWT token
    const token = jwt.sign(
      { 
        userId: userData.id, 
        email: userData.email 
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
        email: userData.email,
        phone: userData.phone,
        full_name: userData.full_name,
        display_name: googleName,
        kyc_status: userData.kyc_status,
        balance: parseFloat(userData.balance),
        photo_url: photoUrl,
        login_method: 'google'
      }
    });
  } catch (error) {
    console.error('Google login error:', error);
    res.status(500).json({ error: 'Login failed. Please try again.' });
  }
});

module.exports = router;

const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// Admin authentication middleware
const adminAuth = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Get user from database
    const result = await pool.query(
      'SELECT * FROM users WHERE id = $1',
      [decoded.userId]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    const user = result.rows[0];

    // Check if user is admin
    if (user.role !== 'admin' && user.role !== 'super_admin') {
      return res.status(403).json({ error: 'Access denied. Admin only.' });
    }

    req.user = user;
    req.userId = user.id;
    req.isAdmin = true;
    req.isSuperAdmin = user.role === 'super_admin';
    
    next();
  } catch (error) {
    console.error('Admin auth error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Super admin only middleware
const superAdminAuth = async (req, res, next) => {
  try {
    await adminAuth(req, res, () => {
      if (!req.isSuperAdmin) {
        return res.status(403).json({ error: 'Super admin access required' });
      }
      next();
    });
  } catch (error) {
    res.status(401).json({ error: 'Authentication failed' });
  }
};

module.exports = { adminAuth, superAdminAuth };

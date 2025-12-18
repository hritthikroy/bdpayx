require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateService = require('./services/rateService');

const authRoutes = require('./routes/auth');
const exchangeRoutes = require('./routes/exchange');
const transactionRoutes = require('./routes/transactions');
const adminRoutes = require('./routes/admin');
const chatRoutes = require('./routes/chat');
const walletRoutes = require('./routes/wallet');
const googleAuthRoutes = require('./routes/google-auth');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/auth', googleAuthRoutes);
app.use('/api/exchange', exchangeRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/wallet', walletRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start dynamic rate fluctuation (only once)
if (!global.rateServiceStarted) {
  rateService.startRateFluctuation();
  global.rateServiceStarted = true;
}

// Export for Vercel serverless
module.exports = app;

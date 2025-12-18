require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.NODE_ENV === 'production' ? process.env.FRONTEND_URL : '*',
    methods: ['GET', 'POST'],
    credentials: true
  }
});

// Optimized middleware
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? process.env.FRONTEND_URL : '*',
  credentials: true
}));

app.use(express.json({ limit: '1mb' })); // Reduced from 10mb
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Disable x-powered-by header for security and performance
app.disable('x-powered-by');

// Professional Rate Engine
const ProfessionalRateEngine = require('./professional-rate-engine');

const BASE_RATE = 0.70;
const MIN_RATE = 0.6980;
const MAX_RATE = 0.7020;
const FLUCTUATION_INTERVAL = 15000; // 15 seconds for smooth professional movement

// Initialize professional rate engine
const rateEngine = new ProfessionalRateEngine({
  baseRate: BASE_RATE,
  minRate: MIN_RATE,
  maxRate: MAX_RATE
});

let currentRate = BASE_RATE;
let rateHistory = [BASE_RATE];
let lastUpdateTime = Date.now();

// Store 24 hours of rate history (one entry per hour)
let hourlyRateHistory = [];

// Initialize with 24 hours of historical data using professional engine
function initializeRateHistory() {
  const now = Date.now();
  
  // Generate realistic 24-hour history
  for (let i = 23; i >= 0; i--) {
    const timestamp = now - (i * 60 * 60 * 1000); // Hours ago
    const rate = rateEngine.generateNextRate();
    
    hourlyRateHistory.push({
      rate: rate,
      timestamp: new Date(timestamp).toISOString(),
      hoursAgo: i
    });
  }
  
  // Reset to current rate
  currentRate = rateEngine.getRate();
}

// Initialize history on startup
initializeRateHistory();

// Cache for rate responses
let cachedRateResponse = null;
let cacheExpiry = 0;

// Optimized rate update with professional movement
function updateRate() {
  const oldRate = currentRate;
  
  // Generate next professional rate
  currentRate = rateEngine.generateNextRate();
  lastUpdateTime = Date.now();
  
  // Get market statistics
  const stats = rateEngine.getStats();
  
  // Keep history of last 10 rates
  rateHistory.push(currentRate);
  if (rateHistory.length > 10) {
    rateHistory.shift();
  }
  
  // Update hourly history (shift old data and add new)
  hourlyRateHistory.shift(); // Remove oldest
  hourlyRateHistory.push({
    rate: currentRate,
    timestamp: new Date(lastUpdateTime).toISOString(),
    hoursAgo: 0,
    trend: stats.trend > 0 ? 'bullish' : stats.trend < 0 ? 'bearish' : 'neutral',
    volatility: stats.volatility
  });
  
  // Update hoursAgo for all entries
  hourlyRateHistory.forEach((entry, index) => {
    entry.hoursAgo = hourlyRateHistory.length - 1 - index;
  });
  
  // Clear cache when rate updates
  cachedRateResponse = null;
  cacheExpiry = 0;
  
  // Enhanced logging with market dynamics
  const changePercent = stats.changePercent;
  const trendEmoji = stats.trend > 0.3 ? '📈' : stats.trend < -0.3 ? '📉' : '➡️';
  
  if (Math.abs(changePercent) > 0.005) {
    console.log(
      `${trendEmoji} ${currentRate.toFixed(4)} ` +
      `(${changePercent > 0 ? '+' : ''}${changePercent.toFixed(3)}%) ` +
      `| Trend: ${stats.trend.toFixed(2)} | Vol: ${(stats.volatility * 10000).toFixed(1)}`
    );
  }
  
  // Throttled emit to prevent spam
  const rateData = { 
    base_rate: currentRate,
    previous_rate: oldRate,
    change: stats.change,
    changePercent: stats.changePercent,
    timestamp: new Date().toISOString(),
    market: {
      trend: stats.trend,
      volatility: stats.volatility,
      momentum: stats.momentum
    }
  };
  
  // Only emit if there are connected clients
  if (io.engine.clientsCount > 0) {
    io.emit('rate_updated', rateData);
  }
  
  return currentRate;
}

// Optimized rate fluctuation
function startRateFluctuation() {
  console.log('🔄 Starting optimized rate fluctuation...');
  console.log(`📈 Range: ${MIN_RATE}-${MAX_RATE} | Interval: ${FLUCTUATION_INTERVAL/1000}s`);
  
  // Update immediately
  updateRate();
  
  // Use more efficient timer
  const rateTimer = setInterval(updateRate, FLUCTUATION_INTERVAL);
  
  // Cleanup on process exit
  process.on('SIGTERM', () => clearInterval(rateTimer));
  process.on('SIGINT', () => clearInterval(rateTimer));
}

// Basic health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    env: process.env.NODE_ENV || 'development',
    current_rate: currentRate,
    rate_history: rateHistory
  });
});

// Cached exchange rate endpoint
app.get('/api/exchange/rate', (req, res) => {
  const now = Date.now();
  
  // Return cached response if still valid (cache for 5 seconds)
  if (cachedRateResponse && now < cacheExpiry) {
    return res.json(cachedRateResponse);
  }
  
  // Generate new response
  cachedRateResponse = {
    base_rate: currentRate,
    bdtToInr: currentRate,
    updatedAt: new Date(lastUpdateTime).toISOString(),
    provider: 'enhanced-mock-server',
    history: rateHistory.slice(-3) // Reduced to last 3 rates
  };
  
  cacheExpiry = now + 5000; // Cache for 5 seconds
  
  res.json(cachedRateResponse);
});

// Rate history endpoint for charts (24 hours)
app.get('/api/exchange/rate-history', (req, res) => {
  res.json({
    history: hourlyRateHistory,
    current_rate: currentRate,
    base_rate: BASE_RATE,
    min_rate: MIN_RATE,
    max_rate: MAX_RATE,
    last_updated: new Date(lastUpdateTime).toISOString()
  });
});

// Market statistics endpoint (professional insights)
app.get('/api/exchange/market-stats', (req, res) => {
  const stats = rateEngine.getStats();
  const recentHistory = rateEngine.getHistory(20);
  
  res.json({
    current_rate: currentRate,
    statistics: {
      change: stats.change,
      changePercent: stats.changePercent,
      trend: stats.trend,
      trendDescription: stats.trend > 0.3 ? 'Bullish' : stats.trend < -0.3 ? 'Bearish' : 'Neutral',
      volatility: stats.volatility,
      volatilityLevel: stats.volatility > 0.0005 ? 'High' : stats.volatility > 0.0003 ? 'Medium' : 'Low',
      momentum: stats.momentum,
      avg20: stats.avg20,
      high20: stats.high20,
      low20: stats.low20
    },
    recent_history: recentHistory,
    last_updated: new Date(lastUpdateTime).toISOString()
  });
});

// Pricing tiers endpoint
app.get('/api/exchange/pricing-tiers', (req, res) => {
  res.json([
    { min_amount: 0, max_amount: 1000, markup: 0.005 },
    { min_amount: 1000, max_amount: 5000, markup: 0.003 },
    { min_amount: 5000, max_amount: null, markup: 0.001 }
  ]);
});

// Calculate exchange endpoint
app.post('/api/exchange/calculate', (req, res) => {
  const { amount } = req.body;
  
  if (!amount || amount <= 0) {
    return res.status(400).json({ error: 'Invalid amount' });
  }
  
  // Simple markup calculation
  let markup = 0.005; // Default 0.5%
  if (amount >= 5000) markup = 0.001;
  else if (amount >= 1000) markup = 0.003;
  
  const finalRate = currentRate + markup;
  const convertedAmount = amount * finalRate;
  
  res.json({
    from_amount: amount,
    to_amount: convertedAmount.toFixed(2),
    exchange_rate: finalRate,
    base_rate: currentRate,
    markup: markup
  });
});

// Optimized Socket.io
io.on('connection', (socket) => {
  // Reduced logging for performance
  if (process.env.NODE_ENV === 'development') {
    console.log(`👤 Connected: ${socket.id.substring(0, 8)}...`);
  }
  
  // Send current rate immediately (throttled)
  socket.emit('rate_updated', { 
    base_rate: currentRate,
    timestamp: new Date(lastUpdateTime).toISOString()
  });
  
  socket.on('disconnect', () => {
    // Minimal disconnect logging
    if (process.env.NODE_ENV === 'development') {
      console.log(`👤 Disconnected: ${socket.id.substring(0, 8)}...`);
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler for undefined routes
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(``);
  console.log(`🚀 Enhanced server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Frontend URL: ${process.env.FRONTEND_URL || 'http://localhost:8080'}`);
  console.log(`📊 API endpoints available at: http://localhost:${PORT}/api/health`);
  console.log(`💱 Real-time rate updates enabled`);
  console.log(``);
  
  // Start rate fluctuation after server starts
  startRateFluctuation();
});

module.exports = { app, server };
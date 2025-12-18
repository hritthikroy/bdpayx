require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');

const app = express();
const server = http.createServer(app);

// Performance optimizations
app.set('trust proxy', 1);
app.disable('x-powered-by');

// Minimal middleware for maximum performance
app.use(cors({
  origin: '*',
  credentials: false,
  optionsSuccessStatus: 200
}));

app.use(express.json({ limit: '100kb' }));

// Professional rate service
const ProfessionalRateEngine = require('./professional-rate-engine');

const BASE_RATE = 0.70;
const MIN_RATE = 0.6980;
const MAX_RATE = 0.7020;
const UPDATE_INTERVAL = 15000; // 15 seconds for smoother updates

// Initialize professional rate engine
const rateEngine = new ProfessionalRateEngine({
  baseRate: BASE_RATE,
  minRate: MIN_RATE,
  maxRate: MAX_RATE
});

let currentRate = BASE_RATE;
let lastUpdate = Date.now();

// Professional rate generation
function updateRate() {
  const oldRate = currentRate;
  
  // Generate professional rate
  currentRate = rateEngine.generateNextRate();
  const stats = rateEngine.getStats();
  
  lastUpdate = Date.now();
  
  // Enhanced logging with market dynamics
  const changePercent = stats.changePercent;
  if (Math.abs(changePercent) > 0.01) {
    const trendEmoji = stats.trend > 0.3 ? '📈' : stats.trend < -0.3 ? '📉' : '➡️';
    console.log(
      `${trendEmoji} ${currentRate.toFixed(4)} ` +
      `(${changePercent > 0 ? '+' : ''}${changePercent.toFixed(3)}%)`
    );
  }
}

// Cached response object
let cachedResponse = null;
let cacheTime = 0;

// Ultra-fast rate endpoint
app.get('/api/exchange/rate', (req, res) => {
  const now = Date.now();
  
  // Use cache if less than 3 seconds old
  if (cachedResponse && (now - cacheTime) < 3000) {
    return res.json(cachedResponse);
  }
  
  // Update cache
  cachedResponse = {
    base_rate: currentRate,
    bdtToInr: currentRate,
    updatedAt: new Date(lastUpdate).toISOString(),
    provider: 'optimized-server'
  };
  cacheTime = now;
  
  res.json(cachedResponse);
});

// Minimal health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok',
    rate: currentRate,
    uptime: Math.floor(process.uptime())
  });
});

// Simple calculate endpoint
app.post('/api/exchange/calculate', (req, res) => {
  const { amount } = req.body;
  
  if (!amount || amount <= 0) {
    return res.status(400).json({ error: 'Invalid amount' });
  }
  
  const markup = amount >= 5000 ? 0.001 : (amount >= 1000 ? 0.003 : 0.005);
  const finalRate = currentRate + markup;
  
  res.json({
    from_amount: amount,
    to_amount: (amount * finalRate).toFixed(2),
    exchange_rate: finalRate,
    base_rate: currentRate,
    markup: markup
  });
});

// Pricing tiers
app.get('/api/exchange/pricing-tiers', (req, res) => {
  res.json([
    { min_amount: 0, max_amount: 1000, markup: 0.005 },
    { min_amount: 1000, max_amount: 5000, markup: 0.003 },
    { min_amount: 5000, max_amount: null, markup: 0.001 }
  ]);
});

// Minimal error handling
app.use((err, req, res, next) => {
  res.status(500).json({ error: 'Server error' });
});

app.use('*', (req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Optimized server on port ${PORT}`);
  console.log(`📊 Rate updates every ${UPDATE_INTERVAL/1000}s`);
  
  // Start rate updates
  updateRate();
  setInterval(updateRate, UPDATE_INTERVAL);
});

// Graceful shutdown
process.on('SIGTERM', () => server.close());
process.on('SIGINT', () => server.close());

module.exports = { app, server };
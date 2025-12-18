const http = require('http');
const ProfessionalRateEngine = require('./professional-rate-engine');

// Initialize professional rate engine
const rateEngine = new ProfessionalRateEngine({
  baseRate: 0.70,
  minRate: 0.698,
  maxRate: 0.702
});

// Lightning-fast variables - no objects, just primitives
let rate = 0.70;
let prevRate = 0.70;
let trend = 0;
let timestamp = Date.now();
let isoTime = new Date(timestamp).toISOString();

// Pre-built response strings for instant serving
let rateStr = '{"base_rate":0.70,"bdtToInr":0.70,"updatedAt":"2025-12-17T21:45:00.000Z","provider":"lightning","trend":0}';
let healthStr = '{"status":"ok","rate":0.70}';

// Professional rate update - optimized for frequent updates
const updateRate = () => {
  prevRate = rate;
  
  // Generate professional rate movement
  rate = rateEngine.generateNextRate();
  const stats = rateEngine.getStats();
  trend = stats.trend;
  
  // Update timestamp
  timestamp = Date.now();
  isoTime = new Date(timestamp).toISOString();
  
  // Rebuild strings - template literals are fast
  const change = rate - prevRate;
  rateStr = `{"base_rate":${rate},"bdtToInr":${rate},"updatedAt":"${isoTime}","provider":"lightning","change":${change.toFixed(6)},"trend":${trend.toFixed(2)}}`;
  healthStr = `{"status":"ok","rate":${rate},"trend":${trend.toFixed(2)}}`;
};

// Ultra-minimal server - fastest possible
const server = http.createServer((req, res) => {
  const url = req.url;
  
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
    res.end();
    return;
  }
  
  // Set common headers
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  
  // Fastest routing - string comparison
  if (url === '/api/exchange/rate') {
    res.writeHead(200);
    res.end(rateStr);
  } else if (url === '/api/health') {
    res.writeHead(200);
    res.end(healthStr);
  } else if (url === '/api/exchange/pricing-tiers') {
    res.writeHead(200);
    res.end('[{"min_amount":0,"max_amount":1000,"markup":0.005},{"min_amount":1000,"max_amount":5000,"markup":0.003},{"min_amount":5000,"max_amount":null,"markup":0.001}]');
  } else {
    res.writeHead(404);
    res.end('{"error":"Not found"}');
  }
});

// Start immediately with fast updates
server.listen(3000, () => {
  console.log('⚡ Lightning server ready - 2s updates');
  updateRate();
  
  // 2-second updates for smooth real-time movement
  // Using setInterval is very lightweight - minimal CPU overhead
  setInterval(updateRate, 2000);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n⚡ Shutting down...');
  server.close();
  process.exit(0);
});

process.on('SIGTERM', () => {
  server.close();
  process.exit(0);
});
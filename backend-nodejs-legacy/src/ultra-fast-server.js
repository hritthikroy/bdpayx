const http = require('http');
const url = require('url');
const ProfessionalRateEngine = require('./professional-rate-engine');

// Initialize professional rate engine
const rateEngine = new ProfessionalRateEngine({
  baseRate: 0.70,
  minRate: 0.698,
  maxRate: 0.702
});

// Ultra-minimal rate service with professional movement
let rate = 0.70;
let lastUpdate = Date.now();

// Pre-computed responses for maximum speed
let rateResponse = Buffer.from('{"base_rate":0.70,"bdtToInr":0.70,"updatedAt":"2025-12-17T21:45:00.000Z","provider":"ultra-fast"}');
let healthResponse = Buffer.from('{"status":"ok","rate":0.70,"uptime":0}');

// Professional rate update (optimized for performance)
function updateRate() {
  // Generate professional rate
  rate = rateEngine.generateNextRate();
  const stats = rateEngine.getStats();
  
  lastUpdate = Date.now();
  
  // Pre-compute response buffer for instant serving
  const responseObj = {
    base_rate: rate,
    bdtToInr: rate,
    updatedAt: new Date(lastUpdate).toISOString(),
    provider: "ultra-fast",
    change: stats.change,
    trend: parseFloat(stats.trend.toFixed(2))
  };
  rateResponse = Buffer.from(JSON.stringify(responseObj));
}

// Update health response
function updateHealth() {
  const healthObj = {
    status: "ok",
    rate: rate,
    uptime: Math.floor(process.uptime())
  };
  healthResponse = Buffer.from(JSON.stringify(healthObj));
}

// Ultra-fast HTTP server - no Express overhead
const server = http.createServer((req, res) => {
  const pathname = url.parse(req.url).pathname;
  
  // Set headers once
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  // Handle OPTIONS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }
  
  // Route handling - fastest possible
  if (pathname === '/api/exchange/rate' && req.method === 'GET') {
    res.writeHead(200);
    res.end(rateResponse);
  }
  else if (pathname === '/api/health' && req.method === 'GET') {
    res.writeHead(200);
    res.end(healthResponse);
  }
  else if (pathname === '/api/exchange/calculate' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { amount } = JSON.parse(body);
        if (!amount || amount <= 0) {
          res.writeHead(400);
          res.end('{"error":"Invalid amount"}');
          return;
        }
        
        const markup = amount >= 5000 ? 0.001 : (amount >= 1000 ? 0.003 : 0.005);
        const finalRate = rate + markup;
        const result = {
          from_amount: amount,
          to_amount: (amount * finalRate).toFixed(2),
          exchange_rate: finalRate,
          base_rate: rate,
          markup: markup
        };
        
        res.writeHead(200);
        res.end(JSON.stringify(result));
      } catch (e) {
        res.writeHead(400);
        res.end('{"error":"Invalid JSON"}');
      }
    });
  }
  else if (pathname === '/api/exchange/pricing-tiers' && req.method === 'GET') {
    res.writeHead(200);
    res.end('[{"min_amount":0,"max_amount":1000,"markup":0.005},{"min_amount":1000,"max_amount":5000,"markup":0.003},{"min_amount":5000,"max_amount":null,"markup":0.001}]');
  }
  else {
    res.writeHead(404);
    res.end('{"error":"Not found"}');
  }
});

// Error handling
server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.log('Port 3000 in use, trying 3001...');
    server.listen(3001, '0.0.0.0');
  }
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`⚡ Ultra-fast server: ${PORT}`);
  
  // Initial update
  updateRate();
  updateHealth();
  
  // Fast updates every 10 seconds
  setInterval(() => {
    updateRate();
    updateHealth();
  }, 10000);
});

// Cleanup
process.on('SIGTERM', () => server.close());
process.on('SIGINT', () => server.close());
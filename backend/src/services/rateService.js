// Dynamic Rate Service - Fluctuates between 0.6980 and 0.7020
const pool = require('../config/database');

const BASE_RATE = 0.70;
const MIN_RATE = 0.6980;
const MAX_RATE = 0.7020;
const FLUCTUATION_INTERVAL = 60000; // 60 seconds (matches frontend countdown)

let currentRate = BASE_RATE;

// Generate random rate within range (more realistic movement)
function generateRate() {
  // Smaller, more gradual changes (±0.0005 max per update)
  const maxChange = 0.0005;
  const randomChange = (Math.random() - 0.5) * maxChange * 2;
  
  // Apply change to current rate (not base rate) for smoother movement
  let newRate = currentRate + randomChange;
  
  // Ensure within bounds
  newRate = Math.max(MIN_RATE, Math.min(MAX_RATE, newRate));
  
  // Add slight tendency to return to base rate (mean reversion)
  const pullToBase = (BASE_RATE - newRate) * 0.1;
  newRate += pullToBase;
  
  return parseFloat(newRate.toFixed(4));
}

// Update rate in database
async function updateRate() {
  try {
    currentRate = generateRate();
    
    await pool.query(
      'UPDATE exchange_rates SET base_rate = $1, updated_at = CURRENT_TIMESTAMP WHERE from_currency = $2 AND to_currency = $3',
      [currentRate, 'BDT', 'INR']
    );
    
    console.log(`📊 Rate updated: ${currentRate}`);
    return currentRate;
  } catch (error) {
    console.error('Error updating rate:', error);
  }
}

// Start rate fluctuation
function startRateFluctuation() {
  console.log('🔄 Starting dynamic rate fluctuation...');
  
  // Update immediately
  updateRate();
  
  // Then update every interval
  setInterval(updateRate, FLUCTUATION_INTERVAL);
}

// Get current rate
function getCurrentRate() {
  return currentRate;
}

module.exports = {
  startRateFluctuation,
  getCurrentRate,
  updateRate
};

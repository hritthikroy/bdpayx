const express = require('express');
const pool = require('../config/database');
const redisClient = require('../config/redis');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Get current exchange rate
router.get('/rate', async (req, res) => {
  try {
    // Try to get from cache first
    const cached = await redisClient.get('exchange_rate_BDT_INR');
    
    if (cached) {
      return res.json(JSON.parse(cached));
    }
    
    const result = await pool.query(
      'SELECT * FROM exchange_rates WHERE from_currency = $1 AND to_currency = $2',
      ['BDT', 'INR']
    );
    
    const rate = result.rows[0];
    
    // Cache for 15 seconds
    await redisClient.setEx('exchange_rate_BDT_INR', 15, JSON.stringify(rate));
    
    res.json(rate);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get pricing tiers
router.get('/pricing-tiers', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM pricing_tiers ORDER BY min_amount');
    res.json(result.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Calculate exchange
router.post('/calculate', async (req, res) => {
  try {
    const { amount } = req.body;
    
    // Get base rate
    const rateResult = await pool.query(
      'SELECT base_rate FROM exchange_rates WHERE from_currency = $1 AND to_currency = $2',
      ['BDT', 'INR']
    );
    
    const baseRate = parseFloat(rateResult.rows[0].base_rate);
    
    // Get applicable tier
    const tierResult = await pool.query(
      'SELECT markup FROM pricing_tiers WHERE min_amount <= $1 AND (max_amount > $1 OR max_amount IS NULL) ORDER BY min_amount DESC LIMIT 1',
      [amount]
    );
    
    const markup = tierResult.rows.length > 0 ? parseFloat(tierResult.rows[0].markup) : 0;
    const finalRate = baseRate + markup;
    const convertedAmount = amount * finalRate;
    
    res.json({
      from_amount: amount,
      to_amount: convertedAmount.toFixed(2),
      exchange_rate: finalRate,
      base_rate: baseRate,
      markup: markup
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get payment instructions
router.get('/payment-instructions', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM payment_instructions WHERE is_active = true'
    );
    res.json(result.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;

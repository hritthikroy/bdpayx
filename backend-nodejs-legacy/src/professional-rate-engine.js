/**
 * Professional Rate Engine
 * Simulates realistic forex market behavior with:
 * - Trend-based movements
 * - Volatility clustering
 * - Mean reversion
 * - Momentum effects
 * - Realistic micro-movements
 */

class ProfessionalRateEngine {
  constructor(config = {}) {
    // Base configuration
    this.baseRate = config.baseRate || 0.70;
    this.minRate = config.minRate || 0.6980;
    this.maxRate = config.maxRate || 0.7020;
    
    // Current state
    this.currentRate = this.baseRate;
    this.previousRate = this.baseRate;
    
    // Market dynamics
    this.trend = 0; // -1 to 1 (bearish to bullish)
    this.momentum = 0; // Carries forward movement
    this.volatility = 0.0002; // Current volatility level
    this.baseVolatility = 0.0002;
    this.maxVolatility = 0.0008;
    
    // Trend persistence
    this.trendStrength = 0;
    this.trendDuration = 0;
    this.maxTrendDuration = 20; // Updates before trend change
    
    // Mean reversion parameters
    this.meanReversionStrength = 0.05;
    
    // History tracking
    this.history = [this.baseRate];
    this.maxHistory = 100;
    
    // Statistics
    this.updateCount = 0;
    this.lastSignificantChange = Date.now();
  }
  
  /**
   * Generate next rate with professional market dynamics
   */
  generateNextRate() {
    this.updateCount++;
    
    // 1. Update trend (trends persist but eventually reverse)
    this.updateTrend();
    
    // 2. Update volatility (clustering effect)
    this.updateVolatility();
    
    // 3. Calculate momentum (trends have inertia)
    this.updateMomentum();
    
    // 4. Generate base movement
    const randomComponent = (Math.random() - 0.5) * 2; // -1 to 1
    const trendComponent = this.trend * 0.6; // Trend influence
    const momentumComponent = this.momentum * 0.4; // Momentum influence
    
    // Combine components
    const movement = (randomComponent * 0.3 + trendComponent + momentumComponent) * this.volatility;
    
    // 5. Apply mean reversion (pull towards base rate)
    const distanceFromBase = this.currentRate - this.baseRate;
    const meanReversionForce = -distanceFromBase * this.meanReversionStrength;
    
    // 6. Calculate new rate
    this.previousRate = this.currentRate;
    let newRate = this.currentRate + movement + meanReversionForce;
    
    // 7. Apply bounds with soft limits (realistic resistance)
    newRate = this.applySoftBounds(newRate);
    
    // 8. Round to realistic precision (4 decimal places)
    this.currentRate = parseFloat(newRate.toFixed(4));
    
    // 9. Update history
    this.updateHistory();
    
    return this.currentRate;
  }
  
  /**
   * Update trend with realistic persistence and reversal
   */
  updateTrend() {
    this.trendDuration++;
    
    // Trend reversal conditions
    const shouldReverse = 
      this.trendDuration > this.maxTrendDuration ||
      (this.currentRate >= this.maxRate * 0.999 && this.trend > 0) ||
      (this.currentRate <= this.minRate * 1.001 && this.trend < 0) ||
      Math.random() < 0.05; // 5% random reversal chance
    
    if (shouldReverse) {
      // Reverse or weaken trend
      if (Math.random() < 0.6) {
        // Full reversal
        this.trend = -this.trend * (0.5 + Math.random() * 0.5);
      } else {
        // Weaken trend (consolidation)
        this.trend *= 0.3;
      }
      this.trendDuration = 0;
      this.maxTrendDuration = 10 + Math.floor(Math.random() * 20);
    } else {
      // Strengthen or maintain trend
      const trendChange = (Math.random() - 0.5) * 0.1;
      this.trend = Math.max(-1, Math.min(1, this.trend + trendChange));
    }
    
    // Occasionally start new strong trend
    if (Math.random() < 0.03) {
      this.trend = (Math.random() - 0.5) * 2; // New random trend
      this.trendDuration = 0;
    }
  }
  
  /**
   * Update volatility with clustering effect
   */
  updateVolatility() {
    // Volatility clustering: high volatility tends to follow high volatility
    const recentChange = Math.abs(this.currentRate - this.previousRate);
    
    // Adjust volatility based on recent movement
    if (recentChange > this.volatility * 0.8) {
      // Increase volatility (clustering)
      this.volatility = Math.min(
        this.maxVolatility,
        this.volatility * 1.1
      );
    } else {
      // Decrease volatility (calm down)
      this.volatility = Math.max(
        this.baseVolatility,
        this.volatility * 0.95
      );
    }
    
    // Random volatility spikes (news events)
    if (Math.random() < 0.02) {
      this.volatility = this.baseVolatility * (2 + Math.random() * 2);
    }
  }
  
  /**
   * Update momentum (inertia in price movement)
   */
  updateMomentum() {
    const recentChange = this.currentRate - this.previousRate;
    
    // Momentum carries forward but decays
    this.momentum = this.momentum * 0.7 + recentChange * 30;
    
    // Limit momentum
    this.momentum = Math.max(-1, Math.min(1, this.momentum));
  }
  
  /**
   * Apply soft bounds (prices resist at boundaries)
   */
  applySoftBounds(rate) {
    const range = this.maxRate - this.minRate;
    const buffer = range * 0.1; // 10% buffer zone
    
    // Soft upper bound
    if (rate > this.maxRate - buffer) {
      const excess = rate - (this.maxRate - buffer);
      const resistance = 1 - (excess / buffer) * 0.8; // Increasing resistance
      rate = (this.maxRate - buffer) + excess * Math.max(0.1, resistance);
    }
    
    // Soft lower bound
    if (rate < this.minRate + buffer) {
      const deficit = (this.minRate + buffer) - rate;
      const resistance = 1 - (deficit / buffer) * 0.8;
      rate = (this.minRate + buffer) - deficit * Math.max(0.1, resistance);
    }
    
    // Hard limits
    return Math.max(this.minRate, Math.min(this.maxRate, rate));
  }
  
  /**
   * Update rate history
   */
  updateHistory() {
    this.history.push(this.currentRate);
    if (this.history.length > this.maxHistory) {
      this.history.shift();
    }
  }
  
  /**
   * Get current rate
   */
  getRate() {
    return this.currentRate;
  }
  
  /**
   * Get rate change
   */
  getChange() {
    return this.currentRate - this.previousRate;
  }
  
  /**
   * Get rate change percentage
   */
  getChangePercent() {
    return ((this.currentRate - this.previousRate) / this.previousRate) * 100;
  }
  
  /**
   * Get market statistics
   */
  getStats() {
    const recentHistory = this.history.slice(-20);
    const avg = recentHistory.reduce((a, b) => a + b, 0) / recentHistory.length;
    const high = Math.max(...recentHistory);
    const low = Math.min(...recentHistory);
    
    return {
      current: this.currentRate,
      previous: this.previousRate,
      change: this.getChange(),
      changePercent: this.getChangePercent(),
      trend: this.trend,
      volatility: this.volatility,
      momentum: this.momentum,
      avg20: parseFloat(avg.toFixed(4)),
      high20: high,
      low20: low,
      updates: this.updateCount
    };
  }
  
  /**
   * Get recent history
   */
  getHistory(count = 10) {
    return this.history.slice(-count);
  }
}

module.exports = ProfessionalRateEngine;

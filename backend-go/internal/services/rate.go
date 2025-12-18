package services

import (
	"database/sql"
	"fmt"
	"log"
	"math"
	"math/rand"
	"time"

	"bdpayx-backend/internal/models"
)

type RateService struct {
	db          *sql.DB
	redisClient *RedisService
}

func NewRateService(db *sql.DB, redisClient *RedisService) *RateService {
	return &RateService{
		db:          db,
		redisClient: redisClient,
	}
}

func (s *RateService) GetRates() (map[string]models.ExchangeRate, error) {
	rows, err := s.db.Query(`
		SELECT id, from_currency, to_currency, rate, spread, created_at, updated_at
		FROM exchange_rates`)
	if err != nil {
		return nil, fmt.Errorf("failed to get rates: %w", err)
	}
	defer rows.Close()

	rates := make(map[string]models.ExchangeRate)
	for rows.Next() {
		var rate models.ExchangeRate
		err := rows.Scan(&rate.ID, &rate.FromCurrency, &rate.ToCurrency,
			&rate.Rate, &rate.Spread, &rate.CreatedAt, &rate.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan rate: %w", err)
		}
		key := rate.FromCurrency + "_" + rate.ToCurrency
		rates[key] = rate
	}

	return rates, nil
}

func (s *RateService) GetRate(fromCurrency, toCurrency string) (*models.ExchangeRate, error) {
	var rate models.ExchangeRate
	err := s.db.QueryRow(`
		SELECT id, from_currency, to_currency, rate, spread, created_at, updated_at
		FROM exchange_rates WHERE from_currency = $1 AND to_currency = $2`,
		fromCurrency, toCurrency).Scan(
		&rate.ID, &rate.FromCurrency, &rate.ToCurrency,
		&rate.Rate, &rate.Spread, &rate.CreatedAt, &rate.UpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("exchange rate not found for %s to %s", fromCurrency, toCurrency)
		}
		return nil, fmt.Errorf("failed to get rate: %w", err)
	}
	return &rate, nil
}

func (s *RateService) CalculateExchange(fromCurrency, toCurrency string, amount float64) (*models.ExchangeCalculateResponse, error) {
	rate, err := s.GetRate(fromCurrency, toCurrency)
	if err != nil {
		return nil, err
	}

	// Apply spread to the rate
	adjustedRate := rate.Rate * (1 - rate.Spread)
	toAmount := amount * adjustedRate

	return &models.ExchangeCalculateResponse{
		FromAmount:   amount,
		ToAmount:     math.Round(toAmount*100) / 100, // Round to 2 decimal places
		ExchangeRate: adjustedRate,
		Spread:       rate.Spread,
	}, nil
}

func (s *RateService) UpdateRate(fromCurrency, toCurrency string, newRate float64) error {
	_, err := s.db.Exec(`
		UPDATE exchange_rates 
		SET rate = $1, updated_at = CURRENT_TIMESTAMP
		WHERE from_currency = $2 AND to_currency = $3`,
		newRate, fromCurrency, toCurrency)
	if err != nil {
		return fmt.Errorf("failed to update rate: %w", err)
	}
	return nil
}

func (s *RateService) StartRateFluctuation() {
	log.Println("🔄 Starting rate fluctuation service...")
	
	ticker := time.NewTicker(30 * time.Second) // Update every 30 seconds
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			s.fluctuateRates()
		}
	}
}

func (s *RateService) fluctuateRates() {
	rates, err := s.GetRates()
	if err != nil {
		log.Printf("Error getting rates for fluctuation: %v", err)
		return
	}

	for _, rate := range rates {
		// Generate random fluctuation between -0.5% to +0.5%
		fluctuation := (rand.Float64() - 0.5) * 0.01 // -0.005 to +0.005
		newRate := rate.Rate * (1 + fluctuation)
		
		// Ensure rate doesn't go below a minimum threshold
		minRate := rate.Rate * 0.95 // Don't go below 95% of original
		maxRate := rate.Rate * 1.05 // Don't go above 105% of original
		
		if newRate < minRate {
			newRate = minRate
		} else if newRate > maxRate {
			newRate = maxRate
		}

		err := s.UpdateRate(rate.FromCurrency, rate.ToCurrency, newRate)
		if err != nil {
			log.Printf("Error updating rate %s_%s: %v", rate.FromCurrency, rate.ToCurrency, err)
		}
	}
}
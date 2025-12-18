package database

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

func Initialize(databaseURL string) (*sql.DB, error) {
	// For testing, allow empty database URL
	if databaseURL == "" {
		log.Println("⚠️  No database URL provided, running in test mode")
		return nil, nil
	}

	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		log.Printf("⚠️  Database connection failed: %v", err)
		log.Println("🔄 Running in test mode without database")
		return nil, nil
	}

	if err := db.Ping(); err != nil {
		log.Printf("⚠️  Database ping failed: %v", err)
		log.Println("🔄 Running in test mode without database")
		return nil, nil
	}

	log.Println("✅ Database connected successfully")

	// Create tables if they don't exist
	if err := createTables(db); err != nil {
		return nil, fmt.Errorf("failed to create tables: %w", err)
	}

	return db, nil
}

func createTables(db *sql.DB) error {
	queries := []string{
		`CREATE TABLE IF NOT EXISTS users (
			id SERIAL PRIMARY KEY,
			email VARCHAR(255) UNIQUE NOT NULL,
			password_hash VARCHAR(255),
			full_name VARCHAR(255) NOT NULL,
			phone VARCHAR(20),
			is_verified BOOLEAN DEFAULT FALSE,
			is_admin BOOLEAN DEFAULT FALSE,
			google_id VARCHAR(255),
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		
		`CREATE TABLE IF NOT EXISTS exchange_rates (
			id SERIAL PRIMARY KEY,
			from_currency VARCHAR(3) NOT NULL,
			to_currency VARCHAR(3) NOT NULL,
			rate DECIMAL(10,4) NOT NULL,
			spread DECIMAL(5,4) DEFAULT 0.02,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		
		`CREATE TABLE IF NOT EXISTS transactions (
			id SERIAL PRIMARY KEY,
			user_id INTEGER REFERENCES users(id),
			from_currency VARCHAR(3) NOT NULL,
			to_currency VARCHAR(3) NOT NULL,
			from_amount DECIMAL(15,2) NOT NULL,
			to_amount DECIMAL(15,2) NOT NULL,
			exchange_rate DECIMAL(10,4) NOT NULL,
			status VARCHAR(20) DEFAULT 'pending',
			payment_proof TEXT,
			admin_notes TEXT,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		
		`CREATE TABLE IF NOT EXISTS wallets (
			id SERIAL PRIMARY KEY,
			user_id INTEGER REFERENCES users(id) UNIQUE,
			bdt_balance DECIMAL(15,2) DEFAULT 0,
			inr_balance DECIMAL(15,2) DEFAULT 0,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		
		`CREATE TABLE IF NOT EXISTS wallet_transactions (
			id SERIAL PRIMARY KEY,
			wallet_id INTEGER REFERENCES wallets(id),
			transaction_type VARCHAR(20) NOT NULL,
			currency VARCHAR(3) NOT NULL,
			amount DECIMAL(15,2) NOT NULL,
			balance_after DECIMAL(15,2) NOT NULL,
			description TEXT,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		
		`CREATE TABLE IF NOT EXISTS support_messages (
			id SERIAL PRIMARY KEY,
			user_id INTEGER REFERENCES users(id),
			message TEXT NOT NULL,
			is_admin BOOLEAN DEFAULT FALSE,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
	}

	for _, query := range queries {
		if _, err := db.Exec(query); err != nil {
			return fmt.Errorf("failed to execute query: %w", err)
		}
	}

	// Insert default exchange rates if they don't exist
	defaultRates := []struct {
		from, to string
		rate     float64
	}{
		{"BDT", "INR", 0.70},
		{"INR", "BDT", 1.43},
	}

	for _, rate := range defaultRates {
		_, err := db.Exec(`
			INSERT INTO exchange_rates (from_currency, to_currency, rate) 
			VALUES ($1, $2, $3) 
			ON CONFLICT DO NOTHING`,
			rate.from, rate.to, rate.rate)
		if err != nil {
			return fmt.Errorf("failed to insert default rate: %w", err)
		}
	}

	log.Println("✅ Database tables created/verified successfully")
	return nil
}
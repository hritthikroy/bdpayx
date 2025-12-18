package services

import (
	"database/sql"
	"fmt"

	"bdpayx-backend/internal/models"
)

type WalletService struct {
	db *sql.DB
}

func NewWalletService(db *sql.DB) *WalletService {
	return &WalletService{db: db}
}

func (s *WalletService) GetWallet(userID int) (*models.Wallet, error) {
	var wallet models.Wallet
	
	err := s.db.QueryRow(`
		SELECT id, user_id, bdt_balance, inr_balance, created_at, updated_at
		FROM wallets WHERE user_id = $1`, userID).Scan(
		&wallet.ID, &wallet.UserID, &wallet.BDTBalance, &wallet.INRBalance,
		&wallet.CreatedAt, &wallet.UpdatedAt)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("wallet not found")
		}
		return nil, fmt.Errorf("failed to get wallet: %w", err)
	}
	
	return &wallet, nil
}

func (s *WalletService) Deposit(userID int, currency string, amount float64, description string) error {
	tx, err := s.db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Get current wallet
	wallet, err := s.GetWallet(userID)
	if err != nil {
		return err
	}

	// Update balance based on currency
	var newBalance float64
	var updateQuery string
	
	if currency == "BDT" {
		newBalance = wallet.BDTBalance + amount
		updateQuery = "UPDATE wallets SET bdt_balance = $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2"
	} else if currency == "INR" {
		newBalance = wallet.INRBalance + amount
		updateQuery = "UPDATE wallets SET inr_balance = $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2"
	} else {
		return fmt.Errorf("unsupported currency: %s", currency)
	}

	// Update wallet balance
	_, err = tx.Exec(updateQuery, newBalance, userID)
	if err != nil {
		return fmt.Errorf("failed to update wallet balance: %w", err)
	}

	// Record wallet transaction
	_, err = tx.Exec(`
		INSERT INTO wallet_transactions (wallet_id, transaction_type, currency, amount, balance_after, description, created_at)
		VALUES ($1, 'deposit', $2, $3, $4, $5, CURRENT_TIMESTAMP)`,
		wallet.ID, currency, amount, newBalance, description)
	if err != nil {
		return fmt.Errorf("failed to record wallet transaction: %w", err)
	}

	return tx.Commit()
}

func (s *WalletService) Withdraw(userID int, currency string, amount float64, description string) error {
	tx, err := s.db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Get current wallet
	wallet, err := s.GetWallet(userID)
	if err != nil {
		return err
	}

	// Check balance and update based on currency
	var currentBalance, newBalance float64
	var updateQuery string
	
	if currency == "BDT" {
		currentBalance = wallet.BDTBalance
		newBalance = currentBalance - amount
		updateQuery = "UPDATE wallets SET bdt_balance = $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2"
	} else if currency == "INR" {
		currentBalance = wallet.INRBalance
		newBalance = currentBalance - amount
		updateQuery = "UPDATE wallets SET inr_balance = $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2"
	} else {
		return fmt.Errorf("unsupported currency: %s", currency)
	}

	// Check if sufficient balance
	if currentBalance < amount {
		return fmt.Errorf("insufficient balance: have %.2f %s, need %.2f %s", currentBalance, currency, amount, currency)
	}

	// Update wallet balance
	_, err = tx.Exec(updateQuery, newBalance, userID)
	if err != nil {
		return fmt.Errorf("failed to update wallet balance: %w", err)
	}

	// Record wallet transaction
	_, err = tx.Exec(`
		INSERT INTO wallet_transactions (wallet_id, transaction_type, currency, amount, balance_after, description, created_at)
		VALUES ($1, 'withdraw', $2, $3, $4, $5, CURRENT_TIMESTAMP)`,
		wallet.ID, currency, amount, newBalance, description)
	if err != nil {
		return fmt.Errorf("failed to record wallet transaction: %w", err)
	}

	return tx.Commit()
}

func (s *WalletService) GetTransactionHistory(userID int, limit, offset int) ([]models.WalletTransaction, error) {
	// First get the wallet ID
	wallet, err := s.GetWallet(userID)
	if err != nil {
		return nil, err
	}

	rows, err := s.db.Query(`
		SELECT id, wallet_id, transaction_type, currency, amount, balance_after, description, created_at
		FROM wallet_transactions 
		WHERE wallet_id = $1 
		ORDER BY created_at DESC 
		LIMIT $2 OFFSET $3`,
		wallet.ID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to get wallet transaction history: %w", err)
	}
	defer rows.Close()

	var transactions []models.WalletTransaction
	for rows.Next() {
		var t models.WalletTransaction
		err := rows.Scan(&t.ID, &t.WalletID, &t.TransactionType, &t.Currency,
			&t.Amount, &t.BalanceAfter, &t.Description, &t.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan wallet transaction: %w", err)
		}
		transactions = append(transactions, t)
	}

	return transactions, nil
}
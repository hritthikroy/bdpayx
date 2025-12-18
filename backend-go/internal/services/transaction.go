package services

import (
	"database/sql"
	"fmt"

	"bdpayx-backend/internal/models"
)

type TransactionService struct {
	db *sql.DB
}

func NewTransactionService(db *sql.DB) *TransactionService {
	return &TransactionService{db: db}
}

func (s *TransactionService) CreateTransaction(userID int, req models.CreateTransactionRequest) (*models.Transaction, error) {
	var transaction models.Transaction
	
	err := s.db.QueryRow(`
		INSERT INTO transactions (user_id, from_currency, to_currency, from_amount, to_amount, exchange_rate, status, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		RETURNING id, user_id, from_currency, to_currency, from_amount, to_amount, exchange_rate, status, payment_proof, admin_notes, created_at, updated_at`,
		userID, req.FromCurrency, req.ToCurrency, req.FromAmount, req.ToAmount, req.ExchangeRate).Scan(
		&transaction.ID, &transaction.UserID, &transaction.FromCurrency, &transaction.ToCurrency,
		&transaction.FromAmount, &transaction.ToAmount, &transaction.ExchangeRate, &transaction.Status,
		&transaction.PaymentProof, &transaction.AdminNotes, &transaction.CreatedAt, &transaction.UpdatedAt)
	
	if err != nil {
		return nil, fmt.Errorf("failed to create transaction: %w", err)
	}
	
	return &transaction, nil
}

func (s *TransactionService) GetUserTransactions(userID int, limit, offset int) ([]models.Transaction, error) {
	rows, err := s.db.Query(`
		SELECT id, user_id, from_currency, to_currency, from_amount, to_amount, exchange_rate, status, payment_proof, admin_notes, created_at, updated_at
		FROM transactions 
		WHERE user_id = $1 
		ORDER BY created_at DESC 
		LIMIT $2 OFFSET $3`,
		userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to get user transactions: %w", err)
	}
	defer rows.Close()

	var transactions []models.Transaction
	for rows.Next() {
		var t models.Transaction
		err := rows.Scan(&t.ID, &t.UserID, &t.FromCurrency, &t.ToCurrency,
			&t.FromAmount, &t.ToAmount, &t.ExchangeRate, &t.Status,
			&t.PaymentProof, &t.AdminNotes, &t.CreatedAt, &t.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan transaction: %w", err)
		}
		transactions = append(transactions, t)
	}

	return transactions, nil
}

func (s *TransactionService) GetTransaction(transactionID, userID int) (*models.Transaction, error) {
	var transaction models.Transaction
	
	err := s.db.QueryRow(`
		SELECT id, user_id, from_currency, to_currency, from_amount, to_amount, exchange_rate, status, payment_proof, admin_notes, created_at, updated_at
		FROM transactions 
		WHERE id = $1 AND user_id = $2`,
		transactionID, userID).Scan(
		&transaction.ID, &transaction.UserID, &transaction.FromCurrency, &transaction.ToCurrency,
		&transaction.FromAmount, &transaction.ToAmount, &transaction.ExchangeRate, &transaction.Status,
		&transaction.PaymentProof, &transaction.AdminNotes, &transaction.CreatedAt, &transaction.UpdatedAt)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("transaction not found")
		}
		return nil, fmt.Errorf("failed to get transaction: %w", err)
	}
	
	return &transaction, nil
}

func (s *TransactionService) UpdateTransactionStatus(transactionID int, status, adminNotes string) error {
	_, err := s.db.Exec(`
		UPDATE transactions 
		SET status = $1, admin_notes = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $3`,
		status, adminNotes, transactionID)
	
	if err != nil {
		return fmt.Errorf("failed to update transaction status: %w", err)
	}
	
	return nil
}

func (s *TransactionService) GetAllTransactions(limit, offset int) ([]models.Transaction, error) {
	rows, err := s.db.Query(`
		SELECT id, user_id, from_currency, to_currency, from_amount, to_amount, exchange_rate, status, payment_proof, admin_notes, created_at, updated_at
		FROM transactions 
		ORDER BY created_at DESC 
		LIMIT $1 OFFSET $2`,
		limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to get all transactions: %w", err)
	}
	defer rows.Close()

	var transactions []models.Transaction
	for rows.Next() {
		var t models.Transaction
		err := rows.Scan(&t.ID, &t.UserID, &t.FromCurrency, &t.ToCurrency,
			&t.FromAmount, &t.ToAmount, &t.ExchangeRate, &t.Status,
			&t.PaymentProof, &t.AdminNotes, &t.CreatedAt, &t.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan transaction: %w", err)
		}
		transactions = append(transactions, t)
	}

	return transactions, nil
}
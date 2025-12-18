package models

import (
	"time"
)

type User struct {
	ID           int       `json:"id" db:"id"`
	Email        string    `json:"email" db:"email"`
	PasswordHash string    `json:"-" db:"password_hash"`
	FullName     string    `json:"full_name" db:"full_name"`
	Phone        string    `json:"phone" db:"phone"`
	IsVerified   bool      `json:"is_verified" db:"is_verified"`
	IsAdmin      bool      `json:"is_admin" db:"is_admin"`
	GoogleID     string    `json:"google_id,omitempty" db:"google_id"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
}

type ExchangeRate struct {
	ID           int       `json:"id" db:"id"`
	FromCurrency string    `json:"from_currency" db:"from_currency"`
	ToCurrency   string    `json:"to_currency" db:"to_currency"`
	Rate         float64   `json:"rate" db:"rate"`
	Spread       float64   `json:"spread" db:"spread"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
}

type Transaction struct {
	ID           int       `json:"id" db:"id"`
	UserID       int       `json:"user_id" db:"user_id"`
	FromCurrency string    `json:"from_currency" db:"from_currency"`
	ToCurrency   string    `json:"to_currency" db:"to_currency"`
	FromAmount   float64   `json:"from_amount" db:"from_amount"`
	ToAmount     float64   `json:"to_amount" db:"to_amount"`
	ExchangeRate float64   `json:"exchange_rate" db:"exchange_rate"`
	Status       string    `json:"status" db:"status"`
	PaymentProof string    `json:"payment_proof,omitempty" db:"payment_proof"`
	AdminNotes   string    `json:"admin_notes,omitempty" db:"admin_notes"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
}

type Wallet struct {
	ID         int       `json:"id" db:"id"`
	UserID     int       `json:"user_id" db:"user_id"`
	BDTBalance float64   `json:"bdt_balance" db:"bdt_balance"`
	INRBalance float64   `json:"inr_balance" db:"inr_balance"`
	CreatedAt  time.Time `json:"created_at" db:"created_at"`
	UpdatedAt  time.Time `json:"updated_at" db:"updated_at"`
}

type WalletTransaction struct {
	ID              int       `json:"id" db:"id"`
	WalletID        int       `json:"wallet_id" db:"wallet_id"`
	TransactionType string    `json:"transaction_type" db:"transaction_type"`
	Currency        string    `json:"currency" db:"currency"`
	Amount          float64   `json:"amount" db:"amount"`
	BalanceAfter    float64   `json:"balance_after" db:"balance_after"`
	Description     string    `json:"description" db:"description"`
	CreatedAt       time.Time `json:"created_at" db:"created_at"`
}

type SupportMessage struct {
	ID        int       `json:"id" db:"id"`
	UserID    int       `json:"user_id" db:"user_id"`
	Message   string    `json:"message" db:"message"`
	IsAdmin   bool      `json:"is_admin" db:"is_admin"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// Request/Response DTOs
type RegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
	FullName string `json:"full_name" binding:"required"`
	Phone    string `json:"phone"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type GoogleAuthRequest struct {
	Token string `json:"token" binding:"required"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type ExchangeCalculateRequest struct {
	FromCurrency string  `json:"from_currency" binding:"required"`
	ToCurrency   string  `json:"to_currency" binding:"required"`
	Amount       float64 `json:"amount" binding:"required,gt=0"`
}

type ExchangeCalculateResponse struct {
	FromAmount   float64 `json:"from_amount"`
	ToAmount     float64 `json:"to_amount"`
	ExchangeRate float64 `json:"exchange_rate"`
	Spread       float64 `json:"spread"`
}

type CreateTransactionRequest struct {
	FromCurrency string  `json:"from_currency" binding:"required"`
	ToCurrency   string  `json:"to_currency" binding:"required"`
	FromAmount   float64 `json:"from_amount" binding:"required,gt=0"`
	ToAmount     float64 `json:"to_amount" binding:"required,gt=0"`
	ExchangeRate float64 `json:"exchange_rate" binding:"required,gt=0"`
}

type UpdateTransactionStatusRequest struct {
	Status     string `json:"status" binding:"required"`
	AdminNotes string `json:"admin_notes"`
}

type WalletDepositRequest struct {
	Currency string  `json:"currency" binding:"required"`
	Amount   float64 `json:"amount" binding:"required,gt=0"`
}

type WalletWithdrawRequest struct {
	Currency string  `json:"currency" binding:"required"`
	Amount   float64 `json:"amount" binding:"required,gt=0"`
}
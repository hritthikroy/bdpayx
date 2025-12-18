package services

import (
	"database/sql"
	"fmt"

	"bdpayx-backend/internal/models"
)

type AdminService struct {
	db *sql.DB
}

func NewAdminService(db *sql.DB) *AdminService {
	return &AdminService{db: db}
}

type DashboardStats struct {
	TotalUsers        int     `json:"total_users"`
	TotalTransactions int     `json:"total_transactions"`
	PendingTransactions int   `json:"pending_transactions"`
	TotalVolume       float64 `json:"total_volume"`
	TodayVolume       float64 `json:"today_volume"`
}

func (s *AdminService) GetDashboardStats() (*DashboardStats, error) {
	stats := &DashboardStats{}

	// Get total users
	err := s.db.QueryRow("SELECT COUNT(*) FROM users").Scan(&stats.TotalUsers)
	if err != nil {
		return nil, fmt.Errorf("failed to get total users: %w", err)
	}

	// Get total transactions
	err = s.db.QueryRow("SELECT COUNT(*) FROM transactions").Scan(&stats.TotalTransactions)
	if err != nil {
		return nil, fmt.Errorf("failed to get total transactions: %w", err)
	}

	// Get pending transactions
	err = s.db.QueryRow("SELECT COUNT(*) FROM transactions WHERE status = 'pending'").Scan(&stats.PendingTransactions)
	if err != nil {
		return nil, fmt.Errorf("failed to get pending transactions: %w", err)
	}

	// Get total volume (sum of all from_amounts)
	err = s.db.QueryRow("SELECT COALESCE(SUM(from_amount), 0) FROM transactions WHERE status = 'completed'").Scan(&stats.TotalVolume)
	if err != nil {
		return nil, fmt.Errorf("failed to get total volume: %w", err)
	}

	// Get today's volume
	err = s.db.QueryRow(`
		SELECT COALESCE(SUM(from_amount), 0) 
		FROM transactions 
		WHERE status = 'completed' AND DATE(created_at) = CURRENT_DATE`).Scan(&stats.TodayVolume)
	if err != nil {
		return nil, fmt.Errorf("failed to get today volume: %w", err)
	}

	return stats, nil
}

func (s *AdminService) GetAllUsers(limit, offset int) ([]models.User, error) {
	rows, err := s.db.Query(`
		SELECT id, email, full_name, phone, is_verified, is_admin, created_at, updated_at
		FROM users 
		ORDER BY created_at DESC 
		LIMIT $1 OFFSET $2`,
		limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to get users: %w", err)
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var u models.User
		err := rows.Scan(&u.ID, &u.Email, &u.FullName, &u.Phone,
			&u.IsVerified, &u.IsAdmin, &u.CreatedAt, &u.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan user: %w", err)
		}
		users = append(users, u)
	}

	return users, nil
}

func (s *AdminService) UpdateUserStatus(userID int, isVerified bool) error {
	_, err := s.db.Exec(`
		UPDATE users 
		SET is_verified = $1, updated_at = CURRENT_TIMESTAMP
		WHERE id = $2`,
		isVerified, userID)
	
	if err != nil {
		return fmt.Errorf("failed to update user status: %w", err)
	}
	
	return nil
}

func (s *AdminService) UpdateExchangeRate(fromCurrency, toCurrency string, rate float64) error {
	_, err := s.db.Exec(`
		UPDATE exchange_rates 
		SET rate = $1, updated_at = CURRENT_TIMESTAMP
		WHERE from_currency = $2 AND to_currency = $3`,
		rate, fromCurrency, toCurrency)
	
	if err != nil {
		return fmt.Errorf("failed to update exchange rate: %w", err)
	}
	
	return nil
}
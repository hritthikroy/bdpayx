package services

import (
	"database/sql"
	"fmt"
	"time"

	"bdpayx-backend/internal/models"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	db        *sql.DB
	jwtSecret string
}

func NewAuthService(db *sql.DB, jwtSecret string) *AuthService {
	return &AuthService{
		db:        db,
		jwtSecret: jwtSecret,
	}
}

func (s *AuthService) Register(req models.RegisterRequest) (*models.AuthResponse, error) {
	// Check if user already exists
	var exists bool
	err := s.db.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)", req.Email).Scan(&exists)
	if err != nil {
		return nil, fmt.Errorf("failed to check user existence: %w", err)
	}
	if exists {
		return nil, fmt.Errorf("user with email %s already exists", req.Email)
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	// Insert user
	var user models.User
	err = s.db.QueryRow(`
		INSERT INTO users (email, password_hash, full_name, phone, created_at, updated_at)
		VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		RETURNING id, email, full_name, phone, is_verified, is_admin, created_at, updated_at`,
		req.Email, string(hashedPassword), req.FullName, req.Phone).Scan(
		&user.ID, &user.Email, &user.FullName, &user.Phone,
		&user.IsVerified, &user.IsAdmin, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	// Create wallet for user
	_, err = s.db.Exec(`
		INSERT INTO wallets (user_id, created_at, updated_at)
		VALUES ($1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
		user.ID)
	if err != nil {
		return nil, fmt.Errorf("failed to create wallet: %w", err)
	}

	// Generate JWT token
	token, err := s.generateToken(user.ID, user.IsAdmin)
	if err != nil {
		return nil, fmt.Errorf("failed to generate token: %w", err)
	}

	return &models.AuthResponse{
		Token: token,
		User:  user,
	}, nil
}

func (s *AuthService) Login(req models.LoginRequest) (*models.AuthResponse, error) {
	var user models.User
	var passwordHash string

	err := s.db.QueryRow(`
		SELECT id, email, password_hash, full_name, phone, is_verified, is_admin, created_at, updated_at
		FROM users WHERE email = $1`, req.Email).Scan(
		&user.ID, &user.Email, &passwordHash, &user.FullName, &user.Phone,
		&user.IsVerified, &user.IsAdmin, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("invalid email or password")
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	// Check password
	err = bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(req.Password))
	if err != nil {
		return nil, fmt.Errorf("invalid email or password")
	}

	// Generate JWT token
	token, err := s.generateToken(user.ID, user.IsAdmin)
	if err != nil {
		return nil, fmt.Errorf("failed to generate token: %w", err)
	}

	return &models.AuthResponse{
		Token: token,
		User:  user,
	}, nil
}

func (s *AuthService) GetUserByID(userID int) (*models.User, error) {
	var user models.User
	err := s.db.QueryRow(`
		SELECT id, email, full_name, phone, is_verified, is_admin, created_at, updated_at
		FROM users WHERE id = $1`, userID).Scan(
		&user.ID, &user.Email, &user.FullName, &user.Phone,
		&user.IsVerified, &user.IsAdmin, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}
	return &user, nil
}

func (s *AuthService) generateToken(userID int, isAdmin bool) (string, error) {
	claims := jwt.MapClaims{
		"user_id":  userID,
		"is_admin": isAdmin,
		"exp":      time.Now().Add(time.Hour * 24 * 7).Unix(), // 7 days
		"iat":      time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}
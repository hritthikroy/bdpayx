package config

import (
	"os"
	"strconv"
)

type Config struct {
	Port        string
	GinMode     string
	DatabaseURL string
	
	// Database
	DBHost     string
	DBPort     int
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string
	
	// Supabase
	SupabaseURL        string
	SupabaseAnonKey    string
	SupabaseServiceKey string
	
	// Redis
	RedisHost     string
	RedisPort     int
	RedisPassword string
	
	// JWT
	JWTSecret   string
	JWTExpiresIn string
	
	// File Upload
	UploadDir           string
	SupabaseStorageBucket string
	
	// Google OAuth
	GoogleClientID     string
	GoogleClientSecret string
	
	// Frontend
	FrontendURL string
}

func Load() *Config {
	cfg := &Config{
		Port:    getEnv("PORT", "3000"),
		GinMode: getEnv("GIN_MODE", "debug"),
		
		// Database
		DBHost:     getEnv("DB_HOST", "localhost"),
		DBPort:     getEnvAsInt("DB_PORT", 5432),
		DBUser:     getEnv("DB_USER", "postgres"),
		DBPassword: getEnv("DB_PASSWORD", ""),
		DBName:     getEnv("DB_NAME", "bdpayx"),
		DBSSLMode:  getEnv("DB_SSL_MODE", "disable"),
		
		// Supabase
		SupabaseURL:        getEnv("SUPABASE_URL", ""),
		SupabaseAnonKey:    getEnv("SUPABASE_ANON_KEY", ""),
		SupabaseServiceKey: getEnv("SUPABASE_SERVICE_KEY", ""),
		
		// Redis
		RedisHost:     getEnv("REDIS_HOST", ""),
		RedisPort:     getEnvAsInt("REDIS_PORT", 6379),
		RedisPassword: getEnv("REDIS_PASSWORD", ""),
		
		// JWT
		JWTSecret:   getEnv("JWT_SECRET", "currency_exchange_secret_key_2024"),
		JWTExpiresIn: getEnv("JWT_EXPIRES_IN", "168h"),
		
		// File Upload
		UploadDir:           getEnv("UPLOAD_DIR", "./uploads"),
		SupabaseStorageBucket: getEnv("SUPABASE_STORAGE_BUCKET", "exchange-proofs"),
		
		// Google OAuth
		GoogleClientID:     getEnv("GOOGLE_CLIENT_ID", ""),
		GoogleClientSecret: getEnv("GOOGLE_CLIENT_SECRET", ""),
		
		// Frontend
		FrontendURL: getEnv("FRONTEND_URL", "http://localhost:8080"),
	}
	
	// Set database URL
	if cfg.SupabaseURL != "" {
		cfg.DatabaseURL = getEnv("DB_CONNECTION_STRING", "")
	} else {
		cfg.DatabaseURL = buildDatabaseURL(cfg)
	}
	
	return cfg
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

func buildDatabaseURL(cfg *Config) string {
	return "host=" + cfg.DBHost + 
		   " port=" + strconv.Itoa(cfg.DBPort) + 
		   " user=" + cfg.DBUser + 
		   " password=" + cfg.DBPassword + 
		   " dbname=" + cfg.DBName + 
		   " sslmode=" + cfg.DBSSLMode
}
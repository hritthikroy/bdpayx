package main

import (
	"log"
	"os"

	"bdpayx-backend/internal/config"
	"bdpayx-backend/internal/database"
	"bdpayx-backend/internal/handlers"
	"bdpayx-backend/internal/middleware"
	"bdpayx-backend/internal/services"
	"bdpayx-backend/internal/websocket"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Initialize configuration
	cfg := config.Load()

	// Initialize database
	db, err := database.Initialize(cfg.DatabaseURL)
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	if db != nil {
		defer db.Close()
	}

	// Initialize Redis (optional)
	var redisClient *services.RedisService
	if cfg.RedisHost != "" {
		redisClient = services.NewRedisService(cfg.RedisHost, cfg.RedisPort, cfg.RedisPassword)
	}

	// Initialize services
	authService := services.NewAuthService(db, cfg.JWTSecret)
	rateService := services.NewRateService(db, redisClient)
	transactionService := services.NewTransactionService(db)
	walletService := services.NewWalletService(db)
	adminService := services.NewAdminService(db)

	// Initialize WebSocket hub
	wsHub := websocket.NewHub()
	go wsHub.Run()

	// Start rate fluctuation service
	go rateService.StartRateFluctuation()

	// Initialize Gin router
	if cfg.GinMode == "release" {
		gin.SetMode(gin.ReleaseMode)
	}
	
	router := gin.Default()

	// CORS middleware
	corsConfig := cors.DefaultConfig()
	if cfg.GinMode == "release" {
		corsConfig.AllowOrigins = []string{cfg.FrontendURL}
	} else {
		corsConfig.AllowAllOrigins = true
	}
	corsConfig.AllowCredentials = true
	corsConfig.AllowHeaders = []string{"Origin", "Content-Length", "Content-Type", "Authorization"}
	router.Use(cors.New(corsConfig))

	// Request logging middleware
	if cfg.GinMode != "release" {
		router.Use(gin.Logger())
	}

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)
	exchangeHandler := handlers.NewExchangeHandler(rateService)
	transactionHandler := handlers.NewTransactionHandler(transactionService)
	walletHandler := handlers.NewWalletHandler(walletService)
	adminHandler := handlers.NewAdminHandler(adminService)
	wsHandler := handlers.NewWebSocketHandler(wsHub)

	// Health check endpoint
	router.GET("/api/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":    "ok",
			"timestamp": "2024-01-01T00:00:00Z",
			"env":       cfg.GinMode,
		})
	})

	// API routes
	api := router.Group("/api")
	{
		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/google", authHandler.GoogleAuth)
			auth.GET("/profile", middleware.AuthMiddleware(cfg.JWTSecret), authHandler.GetProfile)
			auth.PUT("/profile", middleware.AuthMiddleware(cfg.JWTSecret), authHandler.UpdateProfile)
		}

		// Exchange routes
		exchange := api.Group("/exchange")
		{
			exchange.GET("/rates", exchangeHandler.GetRates)
			exchange.POST("/calculate", exchangeHandler.CalculateExchange)
		}

		// Transaction routes (protected)
		transactions := api.Group("/transactions")
		transactions.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			transactions.POST("/", transactionHandler.CreateTransaction)
			transactions.GET("/", transactionHandler.GetUserTransactions)
			transactions.GET("/:id", transactionHandler.GetTransaction)
			transactions.PUT("/:id/status", transactionHandler.UpdateTransactionStatus)
		}

		// Wallet routes (protected)
		wallet := api.Group("/wallet")
		wallet.Use(middleware.AuthMiddleware(cfg.JWTSecret))
		{
			wallet.GET("/balance", walletHandler.GetBalance)
			wallet.POST("/deposit", walletHandler.Deposit)
			wallet.POST("/withdraw", walletHandler.Withdraw)
			wallet.GET("/history", walletHandler.GetHistory)
		}

		// Admin routes (protected)
		admin := api.Group("/admin")
		admin.Use(middleware.AuthMiddleware(cfg.JWTSecret), middleware.AdminMiddleware())
		{
			admin.GET("/dashboard", adminHandler.GetDashboard)
			admin.GET("/transactions", adminHandler.GetAllTransactions)
			admin.PUT("/transactions/:id/status", adminHandler.UpdateTransactionStatus)
			admin.GET("/users", adminHandler.GetUsers)
			admin.PUT("/users/:id/status", adminHandler.UpdateUserStatus)
			admin.POST("/rates", adminHandler.UpdateRates)
		}

		// WebSocket endpoint
		api.GET("/ws", wsHandler.HandleWebSocket)
	}

	// Static file serving
	router.Static("/uploads", "./uploads")

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("🚀 Server starting on port %s", port)
	log.Printf("🌍 Environment: %s", cfg.GinMode)
	log.Printf("🔗 Frontend URL: %s", cfg.FrontendURL)
	log.Printf("📊 Health check: http://localhost:%s/api/health", port)

	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
# BDPayX Backend (Go)

A high-performance Go backend for the BDT to INR currency exchange platform.

## Features

- **Fast & Efficient**: Built with Go and Gin framework for high performance
- **Real-time Updates**: WebSocket support for live rate updates
- **Secure Authentication**: JWT-based authentication with bcrypt password hashing
- **Database Support**: PostgreSQL with connection pooling
- **Redis Caching**: Optional Redis support for improved performance
- **Admin Dashboard**: Complete admin panel for managing users and transactions
- **Rate Fluctuation**: Automatic exchange rate fluctuation simulation
- **RESTful API**: Clean REST API design with proper error handling

## Quick Start

### Prerequisites

- Go 1.21 or higher
- PostgreSQL database
- Redis (optional)

### Installation

1. Clone and navigate to the Go backend:
```bash
cd backend-go
```

2. Install dependencies:
```bash
go mod tidy
```

3. Copy environment file:
```bash
cp .env.example .env
```

4. Update the `.env` file with your database credentials and other settings.

5. Run the application:
```bash
go run main.go
```

The server will start on `http://localhost:3000`

### Development

For development with auto-reload, install Air:
```bash
go install github.com/cosmtrek/air@latest
air
```

### Building for Production

```bash
go build -o bdpayx-backend main.go
./bdpayx-backend
```

### Docker

Build and run with Docker:
```bash
docker build -t bdpayx-backend .
docker run -p 3000:3000 --env-file .env bdpayx-backend
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile (protected)
- `PUT /api/auth/profile` - Update user profile (protected)

### Exchange
- `GET /api/exchange/rates` - Get current exchange rates
- `POST /api/exchange/calculate` - Calculate exchange amount

### Transactions (Protected)
- `POST /api/transactions` - Create new transaction
- `GET /api/transactions` - Get user transactions
- `GET /api/transactions/:id` - Get specific transaction
- `PUT /api/transactions/:id/status` - Update transaction status

### Wallet (Protected)
- `GET /api/wallet/balance` - Get wallet balance
- `POST /api/wallet/deposit` - Deposit funds
- `POST /api/wallet/withdraw` - Withdraw funds
- `GET /api/wallet/history` - Get transaction history

### Admin (Protected, Admin Only)
- `GET /api/admin/dashboard` - Get dashboard statistics
- `GET /api/admin/transactions` - Get all transactions
- `PUT /api/admin/transactions/:id/status` - Update transaction status
- `GET /api/admin/users` - Get all users
- `PUT /api/admin/users/:id/status` - Update user verification status
- `POST /api/admin/rates` - Update exchange rates

### WebSocket
- `GET /api/ws` - WebSocket connection for real-time updates

### Health Check
- `GET /api/health` - Health check endpoint

## Environment Variables

See `.env.example` for all available configuration options.

Key variables:
- `PORT` - Server port (default: 3000)
- `DB_CONNECTION_STRING` - PostgreSQL connection string
- `JWT_SECRET` - JWT signing secret
- `REDIS_HOST` - Redis host (optional)
- `FRONTEND_URL` - Frontend URL for CORS

## Database Schema

The application automatically creates the following tables:
- `users` - User accounts and profiles
- `exchange_rates` - Currency exchange rates
- `transactions` - Exchange transactions
- `wallets` - User wallet balances
- `wallet_transactions` - Wallet transaction history
- `support_messages` - Support chat messages

## Performance Features

- **Connection Pooling**: Efficient database connection management
- **Goroutines**: Concurrent processing for rate updates
- **Minimal Memory**: Optimized for low memory usage
- **Fast JSON**: High-performance JSON serialization
- **WebSocket**: Real-time communication with minimal overhead

## Migration from Node.js

This Go backend is a complete replacement for the Node.js backend with:
- ✅ All API endpoints migrated
- ✅ Same database schema
- ✅ Compatible authentication
- ✅ WebSocket support
- ✅ Admin functionality
- ✅ Rate fluctuation service
- ⚡ Better performance
- 🔒 Enhanced security

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
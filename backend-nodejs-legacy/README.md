# Currency Exchange Backend API

## Setup

1. Install dependencies:
```bash
npm install
```

2. Setup PostgreSQL database:
```bash
createdb currency_exchange
psql currency_exchange < src/database/schema.sql
```

3. Setup Redis (required for caching):
```bash
# macOS
brew install redis
brew services start redis

# Ubuntu
sudo apt install redis-server
sudo systemctl start redis
```

4. Create `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
# Edit .env with your database credentials
```

5. Create uploads directory:
```bash
mkdir -p uploads/payment-proofs
```

6. Start the server:
```bash
npm run dev
```

## API Endpoints

### Authentication
- POST `/api/auth/register` - Register new user
- POST `/api/auth/login` - Login user
- GET `/api/auth/profile` - Get user profile (requires auth)

### Exchange
- GET `/api/exchange/rate` - Get current exchange rate
- GET `/api/exchange/pricing-tiers` - Get pricing tiers
- POST `/api/exchange/calculate` - Calculate exchange amount
- GET `/api/exchange/payment-instructions` - Get payment instructions (requires auth)

### Transactions
- POST `/api/transactions` - Create new transaction (requires auth)
- POST `/api/transactions/:id/upload-proof` - Upload payment proof (requires auth)
- GET `/api/transactions` - Get user transactions (requires auth)
- GET `/api/transactions/:id` - Get transaction by ID (requires auth)

### Admin
- GET `/api/admin/transactions/pending` - Get pending transactions (requires admin)
- POST `/api/admin/transactions/:id/approve` - Approve transaction (requires admin)
- POST `/api/admin/transactions/:id/reject` - Reject transaction (requires admin)
- POST `/api/admin/exchange-rate` - Update exchange rate (requires admin)

### Chat
- POST `/api/chat/messages` - Send message (requires auth)
- GET `/api/chat/messages` - Get chat history (requires auth)
- GET `/api/chat/notifications` - Get notifications (requires auth)
- PUT `/api/chat/notifications/:id/read` - Mark notification as read (requires auth)

## WebSocket Events

- `connection` - Client connects
- `join_support` - Join support room
- `send_message` - Send chat message
- `receive_message` - Receive chat message
- `disconnect` - Client disconnects

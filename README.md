# 🚀 BDPayX - Currency Exchange Platform v2.0

> **Modern BDT to INR Exchange** - Now with Go backend for 3x better performance!

[![Go](https://img.shields.io/badge/Backend-Go%201.21-blue)](https://golang.org)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter%20Web-blue)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Database-Supabase-green)](https://supabase.com)
[![Performance](https://img.shields.io/badge/Performance-3x%20Faster-brightgreen)]()

---

## ✨ Features

- 💱 **Real-time Exchange Rates** - Live BDT to INR conversion with auto-updates
- 🔐 **Secure Authentication** - Google OAuth + Email/Password login
- 💰 **Wallet System** - Deposit, withdraw, and transfer funds securely
- 💬 **Real-time Chat** - Supabase Realtime support system
- 📊 **Admin Dashboard** - Transaction management & analytics
- 🎁 **Referral System** - Earn rewards by inviting friends
- 📱 **Responsive Design** - Beautiful UI that works on all devices
- 🌊 **Glassmorphic UI** - Modern, professional interface with animations

---

## 🏗️ Tech Stack

### Frontend
- **Flutter Web** - Cross-platform UI framework
- **Provider** - State management
- **Supabase Flutter SDK** - Real-time & storage

### Backend
- **Go + Gin** - High-performance REST API (NEW!)
- **Node.js + Express** - Legacy API (deprecated)
- **Supabase PostgreSQL** - Database
- **Supabase Storage** - File uploads (KYC, receipts)
- **WebSocket** - Real-time connections

### Deployment
- **Vercel** - Serverless hosting (FREE tier)
- **Supabase** - Database & storage (FREE tier)
- **GitHub** - Version control

---

## 🚀 Quick Start

### ⚡ NEW: Go Backend Migration

**Upgrade to 3x faster performance:**

```bash
# Automated migration from Node.js to Go
./migrate-to-go.sh

# Your backend is now 3x faster! 🚀
```

📖 **Migration Documentation:**
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - Complete migration guide
- [backend-go/README.md](backend-go/README.md) - Go backend documentation

---

### Quick Setup (Recommended)

**Prerequisites:**
- Go 1.21+ (for backend)
- Flutter SDK (3.0.0+)
- PostgreSQL or Supabase account

**Setup:**

```bash
# 1. Clone repository
git clone https://github.com/hritthikroy/bdpayx.git
cd bdpayx

# 2. Setup Go Backend
cd backend-go
go mod tidy
cp .env.example .env
# Edit .env with your database credentials

# 3. Setup Flutter
cd ../flutter_app
flutter pub get

# 4. Start development servers
# Terminal 1: Backend
npm run backend:dev

# Terminal 2: Frontend  
npm run frontend:dev

# 5. Access the app
# Frontend: http://localhost:8080
# Backend: http://localhost:3000
# Admin: http://localhost:8081
```

### Alternative: Legacy Node.js Backend

If you need the Node.js backend, it's archived in `backend-nodejs-legacy/`:

```bash
# Restore legacy backend
mv backend-nodejs-legacy backend
cd backend
npm install
cp .env.example .env
npm run dev
```

---

## 📁 Project Structure

```
bdpayx/
├── backend-go/                   # Go Gin API (High Performance!)
│   ├── main.go                  # Application entry point
│   ├── internal/
│   │   ├── config/              # Configuration management
│   │   ├── database/            # Database connection & schema
│   │   ├── handlers/            # HTTP request handlers
│   │   ├── middleware/          # Authentication & middleware
│   │   ├── models/              # Data models & DTOs
│   │   ├── services/            # Business logic
│   │   └── websocket/           # WebSocket hub
│   ├── scripts/                 # Build & deployment scripts
│   ├── Dockerfile               # Container configuration
│   ├── go.mod                   # Go dependencies
│   └── README.md                # Go backend documentation
│
├── flutter_app/                  # Flutter Web App
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── screens/             # UI screens
│   │   │   ├── main_navigation.dart  # Glassmorphic nav
│   │   │   ├── home/            # Home screen
│   │   │   ├── transactions/    # Transaction history
│   │   │   ├── chat/            # Support chat
│   │   │   ├── profile/         # User profile
│   │   │   ├── exchange/        # Exchange flow
│   │   │   ├── wallet/          # Wallet management
│   │   │   └── referral/        # Referral system
│   │   ├── providers/           # State management
│   │   │   ├── auth_provider.dart
│   │   │   ├── exchange_provider.dart
│   │   │   └── chat_provider.dart
│   │   ├── widgets/             # Reusable components
│   │   └── config/              # Configuration
│   │       ├── api_config.dart
│   │       └── supabase_config.dart
│   ├── web/                     # Web assets
│   └── pubspec.yaml
│
├── admin-dashboard/              # Admin Panel
│   ├── index.html               # Dashboard UI
│   ├── login.html               # Admin login
│   ├── app.js                   # Dashboard logic
│   ├── styles.css               # Styles
│   └── charts.js                # Analytics charts
│
├── docs/                         # Documentation
│   ├── VERCEL_QUICK_START.md    # Quick deployment
│   ├── VERCEL_DEPLOYMENT_GUIDE.md
│   ├── MIGRATION_SUMMARY.md     # Technical migration
│   ├── WHATSAPP_REMOVAL_SUMMARY.md
│   ├── GOOGLE_AUTH_SETUP.md     # OAuth setup
│   ├── SUPABASE_SETUP.md        # Database setup
│   ├── ADMIN_SYSTEM_README.md   # Admin guide
│   ├── GLASSMORPHIC_NAV_GUIDE.md
│   ├── SETUP_SUPPORT_DATABASE.md
│   ├── SUPPORT_SYSTEM_SETUP.md
│   └── DIY_AUTO_PAYMENT_SYSTEM.md
│
├── scripts/                      # Utility scripts
│   ├── START_ALL.sh             # Start all servers
│   ├── STOP_ALL.sh              # Stop all servers
│   ├── create-admin.js          # Create admin user
│   ├── setup-auto-payment.js    # Setup payment system
│   ├── setup-auto-payment.sql   # Payment SQL
│   ├── setup-support-tables.js  # Setup support DB
│   └── serve-app.js             # Static file server
│
├── backend-nodejs-legacy/        # Legacy Node.js backend (archived)
├── .env.vercel.example          # Environment template
├── .gitignore
├── .vercelignore
├── vercel.json                  # Main Vercel config
├── package.json
└── README.md                    # This file
```

---

## 🔧 Configuration

### Backend Environment Variables

Create `backend/.env`:

```bash
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...

# Database
DB_CONNECTION_STRING=postgresql://postgres:[password]@db.xxxxx.supabase.co:5432/postgres

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Environment
NODE_ENV=development
PORT=3000
```

### Flutter Configuration

Edit `flutter_app/lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGc...';
}
```

Edit `flutter_app/lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000'; // Local
  // static const String baseUrl = 'https://your-app.vercel.app'; // Production
}
```

---

## 📚 Documentation

### Deployment Guides
- **[VERCEL_QUICK_START.md](docs/VERCEL_QUICK_START.md)** - Deploy in 5 minutes
- **[VERCEL_DEPLOYMENT_GUIDE.md](docs/VERCEL_DEPLOYMENT_GUIDE.md)** - Complete deployment guide
- **[README_VERCEL.md](docs/README_VERCEL.md)** - Vercel-specific README

### Setup Guides
- **[GOOGLE_AUTH_SETUP.md](docs/GOOGLE_AUTH_SETUP.md)** - Configure Google OAuth
- **[SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md)** - Setup Supabase database
- **[ADMIN_SYSTEM_README.md](docs/ADMIN_SYSTEM_README.md)** - Admin panel guide
- **[SUPPORT_SYSTEM_SETUP.md](docs/SUPPORT_SYSTEM_SETUP.md)** - Setup support chat
- **[SETUP_SUPPORT_DATABASE.md](docs/SETUP_SUPPORT_DATABASE.md)** - Support DB schema

### Technical Documentation
- **[MIGRATION_SUMMARY.md](docs/MIGRATION_SUMMARY.md)** - Architecture migration details
- **[WHATSAPP_REMOVAL_SUMMARY.md](docs/WHATSAPP_REMOVAL_SUMMARY.md)** - WhatsApp auth removal
- **[GLASSMORPHIC_NAV_GUIDE.md](docs/GLASSMORPHIC_NAV_GUIDE.md)** - UI implementation
- **[DIY_AUTO_PAYMENT_SYSTEM.md](docs/DIY_AUTO_PAYMENT_SYSTEM.md)** - Payment automation

---

## 🎯 Key Features Explained

### 1. Real-time Exchange Rates
- Live BDT to INR conversion
- Auto-updates every 60 seconds
- Visual countdown timer
- Rate history chart (24 hours)

### 2. Wallet System
- **Deposit**: Add BDT to your wallet
- **Withdraw**: Transfer funds to bank
- **Exchange**: Convert BDT to INR
- **Balance**: Real-time balance updates

### 3. Authentication
- **Google OAuth**: One-click login
- **Email/Password**: Traditional login
- **JWT Tokens**: Secure session management
- **Profile Management**: Update user details

### 4. Admin Dashboard
- User management
- Transaction monitoring
- Exchange rate control
- Analytics & reports
- KYC verification

### 5. Support System
- Real-time chat with Supabase
- File attachments
- Message history
- Admin responses

### 6. Referral System
- Unique referral codes
- Earn rewards for invites
- Track referral earnings
- Automatic bonus credits

---

## 🚀 Deployment

### Vercel Deployment (Recommended)

**Cost: FREE** (for most use cases)

1. **Read the guide**: `cat VERCEL_QUICK_START.md`
2. **Follow 5 simple steps**
3. **Your app is live!**

### Manual Deployment

```bash
# 1. Build Flutter web
cd flutter_app
flutter build web --release

# 2. Deploy backend to Vercel
cd backend
vercel --prod

# 3. Deploy frontend to Vercel
cd ..
vercel --prod

# 4. Configure environment variables in Vercel dashboard
```

---

## 🧪 Testing

### Local Testing

```bash
# Start backend
cd backend && npm run dev

# Start frontend (new terminal)
cd flutter_app && flutter run -d chrome

# Test endpoints
curl http://localhost:3000/api/health
```

### Production Testing

```bash
# Health check
curl https://your-backend.vercel.app/api/health

# Open frontend
open https://your-frontend.vercel.app
```

---

## 💰 Cost Breakdown

### FREE Tier (Recommended for starting)
- **Vercel**: $0/month (100GB bandwidth, unlimited requests)
- **Supabase**: $0/month (500MB database, 1GB storage)
- **Total**: **$0/month** 🎉

### When You Grow
- **Small traffic** (1K users): Still FREE
- **Medium traffic** (10K users): ~$25/month
- **Large traffic** (100K users): ~$45/month

---

## 🔐 Security

- ✅ JWT-based authentication
- ✅ Password hashing (bcrypt)
- ✅ Supabase Row Level Security (RLS)
- ✅ HTTPS by default (Vercel)
- ✅ Environment variable encryption
- ✅ Input validation & sanitization
- ✅ CORS configuration
- ✅ XSS protection

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/AmazingFeature`
3. Commit changes: `git commit -m 'Add AmazingFeature'`
4. Push to branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

---

## 📝 License

MIT License - Feel free to use for your projects!

---

## 🆘 Support

### Issues?
1. Check the documentation in `/docs`
2. Review [VERCEL_DEPLOYMENT_GUIDE.md](docs/VERCEL_DEPLOYMENT_GUIDE.md)
3. Check Vercel deployment logs
4. Verify Supabase connection

### Resources
- [Vercel Documentation](https://vercel.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Documentation](https://docs.flutter.dev)

---

## 🎉 Quick Links

- **Frontend**: http://localhost:8080
- **Backend**: http://localhost:3000
- **Admin Panel**: http://localhost:8080/admin-dashboard
- **GitHub**: https://github.com/hritthikroy/bdpayx

---

**Made with ❤️ using Flutter, Node.js, Vercel & Supabase**

**Ready to deploy?** → Start with [VERCEL_QUICK_START.md](docs/VERCEL_QUICK_START.md)

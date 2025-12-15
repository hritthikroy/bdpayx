# 📁 BDPayX Project Structure

## Overview

Clean, organized project structure for the BDPayX currency exchange platform.

---

## Root Directory

```
bdpayx/
├── backend/                 # Node.js Express API
├── flutter_app/            # Flutter Web Application
├── admin-dashboard/        # Admin Panel (HTML/JS)
├── android-sms-monitor/    # Android SMS monitoring (optional)
├── docs/                   # All documentation
├── scripts/                # Utility scripts
├── node_modules/           # Dependencies (gitignored)
├── .git/                   # Git repository
├── .vscode/                # VS Code settings
├── .env.vercel.example     # Environment template
├── .gitignore              # Git ignore rules
├── .vercelignore           # Vercel ignore rules
├── vercel.json             # Vercel configuration
├── package.json            # Root package config
├── package-lock.json       # Dependency lock
├── README.md               # Main documentation
└── PROJECT_STRUCTURE.md    # This file
```

---

## Backend Structure

```
backend/
├── src/
│   ├── index.js                    # Vercel serverless entry
│   ├── server.js                   # Local development server
│   ├── routes/
│   │   ├── auth.js                 # Authentication endpoints
│   │   ├── exchange.js             # Exchange rate APIs
│   │   ├── wallet.js               # Wallet operations
│   │   ├── transaction.js          # Transaction history
│   │   ├── chat.js                 # Support chat
│   │   ├── admin.js                # Admin operations
│   │   ├── referral.js             # Referral system
│   │   └── upload.js               # File uploads
│   ├── config/
│   │   ├── supabase.js             # Supabase client
│   │   └── database.js             # Database config
│   ├── middleware/
│   │   ├── auth.js                 # JWT verification
│   │   ├── admin.js                # Admin check
│   │   └── validation.js           # Input validation
│   └── services/
│       ├── exchangeRate.js         # Rate calculation
│       └── notification.js         # Notifications
├── vercel.json                     # Vercel config
├── package.json                    # Dependencies
├── .env.example                    # Environment template
└── README.md                       # Backend docs
```

---

## Flutter App Structure

```
flutter_app/
├── lib/
│   ├── main.dart                   # App entry point
│   ├── screens/
│   │   ├── main_navigation.dart    # Bottom nav with glassmorphic design
│   │   ├── home/
│   │   │   └── home_screen.dart    # Home screen with exchange
│   │   ├── transactions/
│   │   │   └── transactions_screen.dart
│   │   ├── chat/
│   │   │   └── support_screen.dart # Real-time chat
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   ├── exchange/
│   │   │   ├── payment_screen.dart
│   │   │   └── confirmation_screen.dart
│   │   ├── wallet/
│   │   │   ├── deposit_screen.dart
│   │   │   └── withdraw_screen.dart
│   │   ├── referral/
│   │   │   └── referral_screen.dart
│   │   └── auth/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── providers/
│   │   ├── auth_provider.dart      # Authentication state
│   │   ├── exchange_provider.dart  # Exchange rates
│   │   ├── wallet_provider.dart    # Wallet state
│   │   └── chat_provider.dart      # Chat state
│   ├── widgets/
│   │   ├── login_popup.dart        # Login modal
│   │   ├── amount_chip.dart        # Quick amount buttons
│   │   ├── rate_chart.dart         # Rate history chart
│   │   └── transaction_card.dart   # Transaction item
│   ├── config/
│   │   ├── api_config.dart         # API endpoints
│   │   └── supabase_config.dart    # Supabase config
│   └── models/
│       ├── user.dart               # User model
│       ├── transaction.dart        # Transaction model
│       └── exchange_rate.dart      # Rate model
├── web/
│   ├── index.html                  # Web entry point
│   ├── manifest.json               # PWA manifest
│   └── icons/                      # App icons
├── build/
│   └── web/                        # Built web app (deployed)
├── pubspec.yaml                    # Flutter dependencies
└── README.md                       # Flutter docs
```

---

## Admin Dashboard Structure

```
admin-dashboard/
├── index.html              # Main dashboard
├── login.html              # Admin login
├── app.js                  # Dashboard logic
├── styles.css              # Dashboard styles
└── charts.js               # Analytics charts
```

---

## Documentation Structure

```
docs/
├── VERCEL_QUICK_START.md           # 5-minute deployment
├── VERCEL_DEPLOYMENT_GUIDE.md      # Complete deployment guide
├── README_VERCEL.md                # Vercel-specific info
├── MIGRATION_SUMMARY.md            # Technical migration details
├── WHATSAPP_REMOVAL_SUMMARY.md     # WhatsApp auth removal
├── GOOGLE_AUTH_SETUP.md            # Google OAuth setup
├── SUPABASE_SETUP.md               # Supabase configuration
├── ADMIN_SYSTEM_README.md          # Admin panel guide
├── GLASSMORPHIC_NAV_GUIDE.md       # UI implementation
├── SETUP_SUPPORT_DATABASE.md       # Support DB schema
├── SUPPORT_SYSTEM_SETUP.md         # Support system setup
└── DIY_AUTO_PAYMENT_SYSTEM.md      # Payment automation
```

---

## Scripts Structure

```
scripts/
├── START_ALL.sh                # Start all servers
├── START_ALL_SERVERS.sh        # Alternative start script
├── STOP_ALL.sh                 # Stop all servers
├── create-admin.js             # Create admin user
├── setup-auto-payment.js       # Setup payment system
├── setup-auto-payment.sql      # Payment SQL schema
├── setup-support-tables.js     # Setup support tables
└── serve-app.js                # Static file server
```

---

## Configuration Files

### Root Level
- **vercel.json** - Vercel deployment configuration
- **.env.vercel.example** - Environment variables template
- **.gitignore** - Git ignore rules
- **.vercelignore** - Vercel deployment ignore rules
- **package.json** - Root package configuration

### Backend
- **backend/vercel.json** - Backend-specific Vercel config
- **backend/.env** - Backend environment variables (not in git)
- **backend/.env.example** - Backend env template

### Flutter
- **flutter_app/pubspec.yaml** - Flutter dependencies
- **flutter_app/web/manifest.json** - PWA configuration

---

## Key Files Explained

### Backend

**src/index.js**
- Vercel serverless entry point
- Exports Express app as serverless function
- Used in production deployment

**src/server.js**
- Local development server
- Runs on http://localhost:3000
- Used for local testing

**src/config/supabase.js**
- Supabase client initialization
- Database connection
- Storage and Realtime setup

### Frontend

**lib/main.dart**
- Flutter app entry point
- Provider initialization
- Theme configuration

**lib/screens/main_navigation.dart**
- Bottom navigation bar
- Glassmorphic design with blur effects
- Water flow animations
- Ripple effects on tab selection

**lib/config/api_config.dart**
- API endpoint configuration
- Environment-based URLs
- Google OAuth client ID

### Admin

**admin-dashboard/index.html**
- Admin dashboard UI
- User management
- Transaction monitoring
- Analytics charts

---

## Build Outputs

### Flutter Web Build
```
flutter_app/build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── assets/
├── icons/
└── canvaskit/
```

### Deployment
- Backend: Deployed to Vercel as serverless functions
- Frontend: Deployed to Vercel as static files
- Database: Hosted on Supabase

---

## Environment Variables

### Backend (.env)
```bash
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...
DB_CONNECTION_STRING=postgresql://...
JWT_SECRET=your-secret-key
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-secret
NODE_ENV=production
PORT=3000
```

### Flutter (hardcoded in config files)
```dart
// lib/config/supabase_config.dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGc...';

// lib/config/api_config.dart
static const String baseUrl = 'https://your-app.vercel.app';
```

---

## Ignored Files/Folders

### .gitignore
- node_modules/
- .env
- .env.local
- *.log
- .DS_Store
- flutter_app/build/ (except build/web/)
- backend/dist/

### .vercelignore
- node_modules/
- .env
- .env.local
- *.log
- .DS_Store
- flutter_app/build/ (except build/web/)

---

## Development Workflow

### Local Development
```bash
# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Flutter
cd flutter_app
flutter run -d chrome

# Terminal 3: Admin (optional)
cd admin-dashboard
python -m http.server 8081
```

### Production Deployment
```bash
# 1. Build Flutter
cd flutter_app
flutter build web --release

# 2. Deploy to Vercel
vercel --prod

# 3. Configure environment variables in Vercel dashboard
```

---

## Database Schema

### Main Tables
- **users** - User accounts
- **wallets** - User balances
- **transactions** - Transaction history
- **exchange_rates** - Currency rates
- **support_messages** - Chat messages
- **referrals** - Referral tracking
- **kyc_documents** - KYC verification

### Supabase Storage Buckets
- **kyc_documents** - KYC files
- **profile_pictures** - User avatars
- **transaction_receipts** - Payment receipts

---

## API Endpoints

### Authentication
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/google
- GET /api/auth/me

### Exchange
- GET /api/exchange/rates
- POST /api/exchange/calculate
- POST /api/exchange/execute

### Wallet
- GET /api/wallet/balance
- POST /api/wallet/deposit
- POST /api/wallet/withdraw

### Transactions
- GET /api/transactions
- GET /api/transactions/:id

### Chat
- GET /api/chat/messages
- POST /api/chat/send
- POST /api/chat/upload

### Admin
- GET /api/admin/users
- GET /api/admin/transactions
- PUT /api/admin/rates
- POST /api/admin/verify-kyc

---

## Clean Structure Benefits

✅ **Organized** - Clear separation of concerns
✅ **Maintainable** - Easy to find and update files
✅ **Scalable** - Simple to add new features
✅ **Professional** - Industry-standard structure
✅ **Documented** - Comprehensive documentation
✅ **Deployable** - Ready for production

---

## Next Steps

1. **Local Development**: Follow README.md setup instructions
2. **Deployment**: Use docs/VERCEL_QUICK_START.md
3. **Configuration**: Update environment variables
4. **Testing**: Test all features locally before deploying

---

**Last Updated**: December 15, 2025
**Status**: ✅ Clean and Organized

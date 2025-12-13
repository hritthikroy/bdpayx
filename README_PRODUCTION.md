# 🚀 BDPayX - Production Deployment

## 📱 About BDPayX

BDPayX is a modern currency exchange platform for converting BDT (Bangladeshi Taka) to INR (Indian Rupee) with secure authentication and instant transactions.

### ✨ Key Features

- **Guest Mode**: Browse without login, smart login popups when needed
- **Google OAuth**: Fast and secure authentication via Google
- **Traditional Login**: Phone/password based authentication
- **Dynamic Updates**: Live rotating announcements for engagement
- **Real-time Rates**: Exchange rates update every 15 seconds
- **Instant Calculator**: Calculate exchange amounts in real-time
- **Secure Transactions**: JWT-based authentication and encrypted data
- **Professional UI**: Modern gradient design with smooth animations

## 🎯 Current Status

✅ **Development Complete**
✅ **All Features Working**
✅ **Test Mode Active**
✅ **Production Ready**

## 📁 Project Structure

```
BDPayX/
├── backend/                    # Node.js Express API
│   ├── src/
│   │   ├── routes/            # API endpoints
│   │   ├── services/          # Business logic
│   │   ├── config/            # Configuration
│   │   └── database/          # Database schemas
│   ├── .env.production.example
│   └── package.json
│
├── flutter_app/               # Flutter mobile/web app
│   ├── lib/
│   │   ├── screens/          # UI screens
│   │   ├── providers/        # State management
│   │   ├── models/           # Data models
│   │   ├── widgets/          # Reusable components
│   │   └── config/           # App configuration
│   └── pubspec.yaml
│
├── deploy.sh                  # Automated deployment script
├── ecosystem.config.js        # PM2 configuration
├── nginx.conf                 # Nginx server config
└── PRODUCTION_DEPLOYMENT.md   # Deployment guide
```

## 🚀 Quick Start (Development)

### Prerequisites

- Node.js 16+
- PostgreSQL 12+
- Flutter SDK 3.0+
- Git

### Setup

```bash
# Clone repository
git clone https://github.com/yourusername/bdpayx.git
cd bdpayx

# Backend setup
cd backend
npm install
cp .env.example .env
# Edit .env with your credentials
npm run dev

# Flutter setup (new terminal)
cd flutter_app
flutter pub get
flutter run -d chrome --web-port=8084
```

### Test Mode

The app runs in test mode by default:
- **Test OTP**: 123456 (works for any phone number)
- **No Twilio setup required**
- **Perfect for development**

## 🌐 Production Deployment

### Quick Deploy

```bash
# 1. Setup server (Ubuntu/Debian)
sudo apt update && sudo apt upgrade -y
sudo apt install -y nodejs npm postgresql nginx

# 2. Install PM2
sudo npm install -g pm2

# 3. Clone and configure
git clone https://github.com/yourusername/bdpayx.git
cd bdpayx
cp backend/.env.production.example backend/.env.production
# Edit .env.production with your values

# 4. Deploy
chmod +x deploy.sh
sudo ./deploy.sh
```

### Detailed Guide

See [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md) for complete instructions including:
- Server setup
- Database configuration
- SSL certificates
- Domain configuration
- Monitoring setup
- Backup strategy

## 📱 Mobile App Build

### Android

```bash
cd flutter_app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
cd flutter_app
flutter build ios --release
# Open in Xcode to archive and upload
```

## 🔐 Security

### Production Checklist

- [x] JWT secret changed to strong random string
- [x] Database password secured
- [x] HTTPS enabled
- [x] CORS configured
- [x] Rate limiting enabled
- [x] Input validation on all endpoints
- [x] SQL injection prevention
- [x] XSS protection

### Environment Variables

Critical variables to change for production:
- `JWT_SECRET` - Use strong random string (min 32 chars)
- `DB_PASSWORD` - Use strong database password
- `TWILIO_AUTH_TOKEN` - Your Twilio auth token
- `ALLOWED_ORIGINS` - Your production domains

## 📊 API Endpoints

### Authentication
- `POST /api/auth/login` - Email/password login
- `POST /api/auth/register` - User registration
- `GET /api/auth/profile` - Get user profile

### Exchange
- `GET /api/exchange/rate` - Get current exchange rate
- `POST /api/exchange/calculate` - Calculate exchange amount
- `POST /api/exchange/create` - Create exchange transaction

### Transactions
- `GET /api/transactions` - Get user transactions
- `GET /api/transactions/:id` - Get transaction details

### Wallet
- `GET /api/wallet/balance` - Get wallet balance
- `POST /api/wallet/deposit` - Deposit funds
- `POST /api/wallet/withdraw` - Withdraw funds

## 🧪 Testing

### Test Mode (Current)

```bash
# Login with phone and password
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+8801234567890","password":"yourpassword"}'
```

### Production Testing

After deployment:
```bash
# Health check
curl https://api.bdpayx.com/health

# Exchange rate
curl https://api.bdpayx.com/api/exchange/rate

# Load test
ab -n 1000 -c 10 https://api.bdpayx.com/api/exchange/rate
```

## 📈 Monitoring

### PM2 Commands

```bash
# View status
pm2 status

# View logs
pm2 logs bdpayx-backend

# Monitor resources
pm2 monit

# Restart
pm2 restart bdpayx-backend
```

### Logs Location

- Backend: `pm2 logs bdpayx-backend`
- Nginx: `/var/log/nginx/bdpayx-*.log`
- PostgreSQL: `/var/log/postgresql/`

## 🔄 Backup

Automated daily backups at 2 AM:
- Database: `/var/backups/bdpayx/db_*.sql.gz`
- Uploads: `/var/backups/bdpayx/uploads_*.tar.gz`
- Retention: 7 days

## 🆘 Troubleshooting

### Backend Not Starting

```bash
pm2 logs bdpayx-backend --lines 50
pm2 restart bdpayx-backend
```

### Database Connection Failed

```bash
# Test connection
psql -U bdpayx_user -d bdpayx_production

# Check credentials
cat backend/.env.production
```

### Google OAuth Not Working

1. Check Google credentials in .env
2. Verify sandbox status (if using sandbox)
3. Check phone number format (+country code)
4. View backend logs: `pm2 logs bdpayx-backend`

## 📞 Support

### Documentation
- [Production Deployment](PRODUCTION_DEPLOYMENT.md)
- [Production Ready Checklist](PRODUCTION_READY.md)
- [Everything Working](EVERYTHING_WORKING.md)
- [Auto Phone Detection](AUTO_PHONE_DETECTION.md)
- [Dynamic Updates](DYNAMIC_UPDATES.md)

### Resources
- Twilio Console: https://console.twilio.com
- PostgreSQL Docs: https://www.postgresql.org/docs/
- Flutter Docs: https://docs.flutter.dev
- PM2 Docs: https://pm2.keymetrics.io

## 🎯 Roadmap

### Phase 1: Launch (Current)
- [x] Guest mode
- [x] Google OAuth login
- [x] Traditional login
- [x] Dynamic updates
- [x] Exchange calculator
- [x] Transaction history

### Phase 2: Enhancement
- [ ] Multiple currency support
- [ ] Referral rewards
- [ ] Push notifications
- [ ] In-app chat support
- [ ] KYC verification
- [ ] Bank account integration

### Phase 3: Scale
- [ ] Mobile apps (Android/iOS)
- [ ] Advanced analytics
- [ ] Admin dashboard
- [ ] API for partners
- [ ] Multi-language support

## 📄 License

Copyright © 2024 BDPayX. All rights reserved.

## 👥 Team

- **Developer**: Your Name
- **Contact**: your.email@example.com
- **Website**: https://bdpayx.com

## 🙏 Acknowledgments

- Flutter team for amazing framework
- Google for OAuth API
- PostgreSQL community
- Node.js ecosystem

---

**Ready to deploy?** Follow [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md) for step-by-step instructions.

**Need help?** Check [PRODUCTION_READY.md](PRODUCTION_READY.md) for complete checklist.

**🚀 Let's launch BDPayX!**

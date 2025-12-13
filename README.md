# BDPayX - Currency Exchange Platform

A modern Flutter web application for BDT to INR currency exchange with real-time rates and secure transactions.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0.0+)
- Node.js (16+)
- PostgreSQL or Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd BDPayX
   ```

2. **Setup Backend**
   ```bash
   cd backend
   npm install
   cp .env.example .env
   # Edit .env with your configuration
   npm start
   ```

3. **Setup Flutter App**
   ```bash
   cd flutter_app
   flutter pub get
   flutter run -d chrome
   ```

## 📁 Project Structure

```
BDPayX/
├── backend/              # Node.js Express backend
│   ├── src/
│   │   ├── routes/      # API routes
│   │   ├── services/    # Business logic
│   │   └── database/    # Database schemas
│   └── package.json
│
├── flutter_app/         # Flutter web application
│   ├── lib/
│   │   ├── screens/     # UI screens
│   │   ├── providers/   # State management
│   │   ├── widgets/     # Reusable widgets
│   │   └── config/      # Configuration
│   └── pubspec.yaml
│
└── README.md
```

## 🎯 Features

- **Real-time Exchange Rates** - Live BDT to INR conversion
- **Secure Authentication** - Google OAuth & traditional login
- **Wallet Management** - Deposit, withdraw, and transfer funds
- **Transaction History** - Complete transaction tracking
- **KYC Verification** - Secure identity verification
- **Referral System** - Earn rewards by referring friends
- **Admin Dashboard** - Manage users and transactions
- **Responsive Design** - Works on all devices

## 🔧 Configuration

### Backend Environment Variables
```env
PORT=3000
DATABASE_URL=postgresql://...
JWT_SECRET=your-secret-key
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

### Flutter Configuration
Edit `flutter_app/lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const String googleClientId = 'your-google-client-id';
}
```

## 🏗️ Build for Production

### Backend
```bash
cd backend
npm run build
npm run start:prod
```

### Flutter Web
```bash
cd flutter_app
flutter build web --release
```

The built files will be in `flutter_app/build/web/`

## 📱 Deployment

### Using Docker
```bash
docker-compose up -d
```

### Manual Deployment
1. Deploy backend to your Node.js hosting
2. Deploy Flutter web build to static hosting (Netlify, Vercel, etc.)
3. Configure environment variables
4. Setup SSL certificates

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm test
```

### Flutter Tests
```bash
cd flutter_app
flutter test
```

## 🔐 Security

- All API endpoints are protected with JWT authentication
- Passwords are hashed using bcrypt
- HTTPS enforced in production
- CORS configured for security
- Input validation on all forms
- XSS protection enabled

## 📊 Database Schema

See `backend/src/database/schema.sql` for the complete database structure.

Key tables:
- `users` - User accounts
- `wallets` - User wallet balances
- `transactions` - Transaction history
- `exchange_rates` - Currency exchange rates
- `kyc_documents` - KYC verification data

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For support, email support@bdpayx.com or join our Slack channel.

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI components
- All contributors who helped build this project

---

**Built with ❤️ using Flutter & Node.js**

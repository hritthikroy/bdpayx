# 🚀 BDPayX - Quick Start Guide

## ✅ Current Status

- ✅ **Backend API**: Running on http://localhost:3000
- ✅ **Database**: Connected (Supabase)
- ✅ **Flutter App**: Ready (needs Flutter SDK)

---

## 📱 Start Flutter Web UI (Recommended for Development)

### Why Flutter Web?
- ✅ No Android emulator needed (saves Mac resources)
- ✅ Hot reload - see changes instantly
- ✅ Easy debugging in Chrome
- ✅ Same code works on Android later

### Step 1: Install Flutter (One-Time)

```bash
brew install --cask flutter
```

This takes 2-3 minutes. After installation, verify:
```bash
flutter --version
```

### Step 2: Start Your App

```bash
./START_WEB_NOW.sh
```

This will:
1. Start backend (if not running)
2. Install Flutter dependencies
3. Launch your app in Chrome
4. Enable hot reload

---

## 🎯 Alternative: Manual Start

### Backend:
```bash
cd backend
npm start
```

### Flutter Web:
```bash
cd flutter_app
flutter pub get
flutter run -d chrome --web-port=8080
```

---

## 📱 Your Flutter App Features

All your original screens:
- ✅ Splash screen
- ✅ Login/Register (Google + Phone)
- ✅ Home with exchange calculator
- ✅ Wallet & transactions
- ✅ Profile & KYC
- ✅ Chat support
- ✅ Referral system

---

## 🔧 Development Workflow

1. **Start app**: `./START_WEB_NOW.sh`
2. **Edit code**: Make changes in `flutter_app/lib/`
3. **See changes**: Press `r` in terminal for hot reload
4. **Full restart**: Press `R` for hot restart

---

## 📦 Build Android APK (When Ready)

```bash
cd flutter_app
flutter build apk --release
```

APK will be in: `flutter_app/build/app/outputs/flutter-apk/`

---

## 🛑 Stop Services

Press `Ctrl+C` in terminal

Or:
```bash
pkill -f "node.*server.js"
pkill -f "flutter run"
```

---

## 📊 API Endpoints

Backend running on http://localhost:3000

- `/api/auth/*` - Authentication
- `/api/exchange/*` - Exchange rates & calculations
- `/api/transactions/*` - Transaction history
- `/api/wallet/*` - Wallet operations
- `/api/chat/*` - Support chat

---

## ✅ Next Steps

1. **Install Flutter**: `brew install --cask flutter`
2. **Start Web UI**: `./START_WEB_NOW.sh`
3. **Edit & Test**: Make changes, see them instantly
4. **Build APK**: When ready for Android

---

## 🆘 Troubleshooting

**Flutter not found:**
```bash
brew install --cask flutter
flutter doctor
```

**Port already in use:**
```bash
lsof -ti:3000 | xargs kill -9
lsof -ti:8080 | xargs kill -9
```

**Backend not starting:**
```bash
cd backend
npm install
npm start
```

---

## 🎉 Ready!

Your Flutter app is ready to run. Just install Flutter and start the web UI!

```bash
brew install --cask flutter
./START_WEB_NOW.sh
```

# 🚀 Quick Start Guide

## Start the Application

### Option 1: Use Start Script (Recommended)
```bash
./scripts/START_ALL.sh
```

### Option 2: Manual Start

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```

**Terminal 2 - Frontend:**
```bash
node scripts/serve-app.js
```

## Access the Application

- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:3000
- **Admin Panel**: http://localhost:8080/admin-dashboard

## Stop the Application

```bash
./scripts/STOP_ALL.sh
```

Or press `Ctrl+C` in each terminal.

---

## Current Status

✅ **Backend**: Running on port 3000
✅ **Frontend**: Running on port 8080
✅ **Database**: Connected
✅ **Redis**: Connected
✅ **Live Rates**: Updating every 60s

---

## Features Available

- 💱 Real-time BDT to INR exchange
- 🔐 Google OAuth + Email login
- 💰 Wallet system (deposit/withdraw)
- 📊 Transaction history
- 💬 Real-time support chat
- 🎁 Referral system
- ⚙️ Admin dashboard

---

## Need Help?

- **Documentation**: See `/docs` folder
- **Setup Guide**: `docs/VERCEL_QUICK_START.md`
- **Project Structure**: `PROJECT_STRUCTURE.md`
- **Main README**: `README.md`

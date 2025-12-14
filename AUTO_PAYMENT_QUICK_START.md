# 🚀 Quick Start: DIY Automatic Payment System

## What You're Building

A system that automatically verifies bKash/Nagad payments without any third-party service:
- Android app monitors SMS on your phone
- When payment arrives, app sends to your server
- Server automatically credits user's wallet
- **100% FREE - No transaction fees!**

## 5-Minute Setup

### Step 1: Backend Setup (2 minutes)

```bash
# 1. Run database setup
node setup-auto-payment.js

# 2. Add to .env file
echo "SMS_WEBHOOK_KEY=$(openssl rand -hex 32)" >> .env

# 3. Restart backend
npm run dev
```

### Step 2: Build Android App (2 minutes)

```bash
# 1. Open Android Studio
# 2. Open the 'android-sms-monitor' folder
# 3. Build > Build Bundle(s) / APK(s) > Build APK(s)
# 4. Transfer APK to your Android phone
# 5. Install the APK
```

### Step 3: Configure Android App (1 minute)

1. Open the app on your phone
2. Enter:
   - **Server URL**: `https://yourdomain.com` (or your server URL)
   - **API Key**: Copy from `.env` file (`SMS_WEBHOOK_KEY`)
3. Click "Save Settings"
4. Grant SMS permissions when prompted

## ✅ You're Done!

### Test It Now

1. **User creates deposit** in your app (e.g., ৳100)
2. **User sends bKash** to your number
3. **SMS arrives** on your Android phone
4. **App detects** payment SMS
5. **Server credits** wallet automatically
6. **User sees** balance updated instantly!

## How It Works

```
Customer Payment → bKash SMS → Android App → Your Server → Wallet Credited
                    (Instant)    (Monitors)   (Verifies)    (Automatic)
```

## Payment Methods Supported

- ✅ bKash
- ✅ Nagad  
- ✅ Rocket
- ✅ Bank transfers (if SMS enabled)

## Important Notes

### Keep Android Device:
- ✅ Plugged in (power)
- ✅ Connected to WiFi/Data
- ✅ App running in background
- ✅ SMS permissions granted

### Security:
- ✅ Use HTTPS for server
- ✅ Keep API key secret
- ✅ Only install app on trusted device

## Troubleshooting

### "No matching deposit found"
- Check `unmatched_payments` table in database
- User might not have created deposit request first
- Amount might differ by more than ±10 Tk

### "SMS not detected"
- Verify SMS permissions granted
- Check if SMS is from bKash/Nagad (16247/16167)
- View Android app logs

### "Server not receiving"
- Check server URL in app (must be HTTPS)
- Verify API key matches `.env` file
- Check server logs: `tail -f backend.log`

## Admin Dashboard

View unmatched payments:
```bash
curl -X GET http://localhost:3000/api/sms-webhook/unmatched \
  -H "X-API-Key: YOUR_SMS_WEBHOOK_KEY"
```

## Database Tables

### `wallet_deposits`
- Added `transaction_id` column for SMS transaction IDs

### `unmatched_payments` (NEW)
- Stores payments that couldn't be auto-matched
- Review these manually in admin panel

## Cost Comparison

| Service | Setup | Monthly | Per Transaction |
|---------|-------|---------|-----------------|
| **Your DIY System** | Free | Free | Free |
| 1dokan.shop | Free | ~৳500 | ~1-2% |
| Other Gateways | ৳5000+ | ৳1000+ | 2-3% |

## Next Steps

1. ✅ Test with small amounts (৳10-50)
2. ✅ Monitor for 24 hours
3. ✅ Add admin UI for unmatched payments
4. ✅ Set up backup Android device
5. ✅ Go live!

## Support

- Check logs: `tail -f backend.log`
- Test webhook: `curl http://localhost:3000/api/sms-webhook/health`
- View unmatched: Check database table `unmatched_payments`

---

**Questions?** Check `DIY_AUTO_PAYMENT_SYSTEM.md` for detailed documentation.

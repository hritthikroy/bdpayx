# 📱 Easy Android App Build Guide

## 🎯 You Have 3 Options

### Option 1: Automatic Script (Easiest if you have Homebrew)

```bash
./install-and-build.sh
```

This will:
- Check for Java (install if needed)
- Check for Android SDK
- Build the APK automatically

---

### Option 2: Install Android Studio (Most Reliable - RECOMMENDED)

This is the **easiest and most reliable** method!

#### Step 1: Download Android Studio
```
https://developer.android.com/studio
```
- Click "Download Android Studio"
- Choose Mac version
- Download (~1GB)

#### Step 2: Install Android Studio
1. Open the downloaded DMG file
2. Drag Android Studio to Applications
3. Open Android Studio from Applications
4. Follow the setup wizard:
   - Click "Next" through the screens
   - Choose "Standard" installation
   - Wait for SDK download (5-10 minutes)
   - Click "Finish"

#### Step 3: Open Your Project
1. In Android Studio, click "Open"
2. Navigate to your project folder
3. Select the `android-sms-monitor` folder
4. Click "Open"
5. Wait for Gradle sync (2-3 minutes)

#### Step 4: Build APK
1. Go to menu: **Build > Build Bundle(s) / APK(s) > Build APK(s)**
2. Wait for build (2-5 minutes)
3. When done, click "locate" in the notification
4. Your APK is ready!

**APK Location:**
```
android-sms-monitor/app/build/outputs/apk/debug/app-debug.apk
```

---

### Option 3: Use Online APK Builder (No Installation)

If you don't want to install anything:

#### Step 1: Zip the Project
```bash
zip -r android-sms-monitor.zip android-sms-monitor/
```

#### Step 2: Use Online Builder
Search Google for:
- "online android apk builder"
- "build apk online free"

Popular options:
- AppGyver
- Thunkable
- Or search for "gradle online compiler"

#### Step 3: Upload & Build
1. Upload your zip file
2. Wait for build
3. Download the APK

**Note:** Online builders may have limitations or require signup.

---

## 🚀 After Building: Install on Phone

### Step 1: Transfer APK to Phone

**Method A: USB Cable**
1. Connect phone to computer
2. Copy APK to phone's Downloads folder

**Method B: Email**
1. Email the APK to yourself
2. Open email on phone
3. Download attachment

**Method C: Cloud Storage**
1. Upload APK to Google Drive/Dropbox
2. Download on phone

**Method D: ADB (if installed)**
```bash
adb install android-sms-monitor/app/build/outputs/apk/debug/app-debug.apk
```

### Step 2: Enable Unknown Sources

On your Android phone:
1. Go to **Settings**
2. Go to **Security** or **Apps**
3. Find **Install Unknown Apps** or **Unknown Sources**
4. Enable for your file manager or browser

### Step 3: Install APK

1. Open file manager on phone
2. Navigate to Downloads
3. Tap the APK file
4. Tap "Install"
5. Wait for installation
6. Tap "Open"

---

## ⚙️ Configure the App

Once installed and opened:

### Enter Server URL
```
https://yourdomain.com
```
Replace `yourdomain.com` with your actual domain or server IP.

For local testing, you can use:
```
http://YOUR_COMPUTER_IP:8081
```

### Enter API Key
```
eed2e21ff245cda9ceeea36552dac08a0d5e7727058a9da0d29296b1ebb0fd65
```
Copy this exactly as shown.

### Grant Permissions
1. Tap "Save Settings"
2. When prompted, tap "Allow" for SMS permissions
3. Verify status shows "✓ Monitoring active"

---

## 🧪 Test the System

### Test 1: Check App Status
Open the app and verify:
- ✓ Permissions: Granted
- ✓ Settings: Configured
- ✓ Monitoring active

### Test 2: Test with Real Payment

1. **Create deposit in your app**
   - Amount: ৳50 (small test amount)
   - Method: bKash

2. **Send bKash payment**
   - Send ৳50 to your bKash number
   - Wait for SMS

3. **Watch the magic!**
   - SMS arrives on phone
   - App detects it
   - Server credits wallet
   - User gets notification

### Test 3: Check Logs

**On phone (via USB):**
```bash
adb logcat | grep "BDPayX"
```

**On server:**
```bash
tail -f backend.log | grep "SMS received"
```

---

## 🐛 Troubleshooting

### Build Fails in Android Studio

**Solution 1: Clean and Rebuild**
1. Build > Clean Project
2. Build > Rebuild Project

**Solution 2: Invalidate Caches**
1. File > Invalidate Caches / Restart
2. Click "Invalidate and Restart"

**Solution 3: Update Gradle**
1. File > Project Structure
2. Update Gradle version if prompted

### App Crashes on Install

**Check Android Version:**
- Minimum required: Android 5.0 (Lollipop)
- Check phone's Android version in Settings

### SMS Not Detected

**Check Permissions:**
1. Open app
2. Verify "Permissions: Granted"
3. If not, go to phone Settings > Apps > BDPayX Monitor > Permissions
4. Enable SMS permissions

**Check SMS Format:**
- SMS must be from bKash (16247), Nagad (16167), or Rocket
- SMS must contain payment keywords

### Server Not Receiving

**Check Configuration:**
1. Verify server URL is correct
2. Verify API key matches backend
3. Check phone has internet connection
4. Check server is running and accessible

**Test Server:**
```bash
curl http://localhost:8081/api/sms-webhook/health
```

---

## 📊 What Happens After Setup

```
1. Customer creates deposit (৳100)
         ↓
2. Customer sends bKash payment
         ↓
3. SMS arrives on your phone
         ↓
4. App detects SMS (bKash/Nagad/Rocket)
         ↓
5. App parses: amount, sender, transaction ID
         ↓
6. App sends to your server
         ↓
7. Server matches with pending deposit
         ↓
8. Server credits wallet automatically
         ↓
9. User gets notification
         ↓
10. DONE! (All in <5 seconds)
```

---

## 🎯 Recommended: Option 2 (Android Studio)

**Why Android Studio is best:**
- ✅ Most reliable
- ✅ Visual interface
- ✅ Easy to use
- ✅ 99% success rate
- ✅ Can rebuild anytime
- ✅ Can modify code if needed

**Time investment:**
- Download: 5 minutes
- Install: 5 minutes
- Setup: 5 minutes
- Build: 5 minutes
- **Total: 20 minutes**

---

## 💡 Quick Start Command

If you have Homebrew and want to try automatic:
```bash
./install-and-build.sh
```

Otherwise, download Android Studio:
```
https://developer.android.com/studio
```

---

## 📞 Need Help?

1. **Check BUILD_ANDROID_APP.html** - Visual guide
2. **Check android-sms-monitor/BUILD_INSTRUCTIONS.md** - Detailed steps
3. **Check error messages** - They usually tell you what's wrong

---

## ✅ Success Checklist

- [ ] Android Studio installed (or build method chosen)
- [ ] Project opened in Android Studio
- [ ] Gradle sync completed
- [ ] APK built successfully
- [ ] APK transferred to phone
- [ ] App installed on phone
- [ ] Server URL configured
- [ ] API key configured
- [ ] SMS permissions granted
- [ ] Status shows "Monitoring active"
- [ ] Tested with real payment
- [ ] Wallet credited successfully

---

**Ready to build?** Choose your method and let's go! 🚀

# 📱 Build Instructions for BDPayX SMS Monitor

## ✅ Project Structure Complete!

The Android project is now fully set up and ready to build.

## 🚀 Option 1: Build with Android Studio (Easiest)

### Step 1: Install Android Studio
Download from: https://developer.android.com/studio

### Step 2: Open Project
1. Launch Android Studio
2. Click "Open an Existing Project"
3. Navigate to and select the `android-sms-monitor` folder
4. Wait for Gradle sync to complete

### Step 3: Build APK
1. Go to: **Build > Build Bundle(s) / APK(s) > Build APK(s)**
2. Wait for build to complete (2-5 minutes)
3. Click "locate" in the notification to find the APK
4. APK location: `app/build/outputs/apk/debug/app-debug.apk`

### Step 4: Install on Device
1. Transfer APK to your Android phone (via USB, email, or cloud)
2. On phone: Enable "Install from Unknown Sources" in Settings
3. Tap the APK file to install
4. Open the app and configure

## 🛠️ Option 2: Build from Command Line

### Prerequisites
- Java JDK 11 or higher
- Android SDK installed

### Build Commands

```bash
cd android-sms-monitor

# Make gradlew executable (if not already)
chmod +x gradlew

# Build debug APK
./gradlew assembleDebug

# Build release APK (unsigned)
./gradlew assembleRelease
```

### Find Your APK
```bash
# Debug APK
ls -lh app/build/outputs/apk/debug/app-debug.apk

# Release APK
ls -lh app/build/outputs/apk/release/app-release-unsigned.apk
```

## 📲 Install APK on Device

### Via USB (ADB)
```bash
# Install debug APK
adb install app/build/outputs/apk/debug/app-debug.apk

# Or if device already has the app
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### Via File Transfer
1. Copy APK to phone
2. Use file manager to open APK
3. Tap "Install"

## ⚙️ Configure the App

Once installed:

1. **Open the app**
2. **Enter Server URL**: `https://yourdomain.com`
3. **Enter API Key**: `eed2e21ff245cda9ceeea36552dac08a0d5e7727058a9da0d29296b1ebb0fd65`
4. **Click "Save Settings"**
5. **Grant SMS permissions** when prompted
6. **Verify status** shows "✓ Monitoring active"

## 🧪 Test the App

### Test SMS Detection
Send a test SMS to the device:
```
From: bKash
Body: You have received Tk 100.00 from 01712345678. TrxID: TEST123
```

### Check Logs (via USB)
```bash
# View all logs
adb logcat

# Filter for our app
adb logcat | grep "BDPayX"

# Filter for SMS receiver
adb logcat | grep "SmsReceiver"
```

## 🐛 Troubleshooting

### Build Fails
```bash
# Clean and rebuild
./gradlew clean
./gradlew assembleDebug
```

### Gradle Issues
```bash
# Update Gradle wrapper
./gradlew wrapper --gradle-version=8.0
```

### SDK Not Found
Set ANDROID_HOME environment variable:
```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

## 📦 Project Structure

```
android-sms-monitor/
├── app/
│   ├── src/main/
│   │   ├── java/com/bdpayx/smsmonitor/
│   │   │   ├── MainActivity.java       # Main UI
│   │   │   ├── SmsReceiver.java       # SMS detector
│   │   │   └── ApiService.java        # Server communication
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   └── activity_main.xml  # UI layout
│   │   │   └── values/
│   │   │       ├── strings.xml
│   │   │       └── colors.xml
│   │   └── AndroidManifest.xml        # App config
│   └── build.gradle                   # App dependencies
├── build.gradle                       # Project config
├── settings.gradle                    # Project settings
└── gradlew                           # Gradle wrapper
```

## ✅ Verification Checklist

After building and installing:

- [ ] App installs without errors
- [ ] App opens and shows configuration screen
- [ ] Can enter server URL and API key
- [ ] Settings save successfully
- [ ] SMS permissions can be granted
- [ ] Status shows "Monitoring active"
- [ ] Test SMS is detected (check logs)
- [ ] Server receives webhook (check backend logs)

## 🎯 Next Steps

1. Build the APK using one of the methods above
2. Install on Android device
3. Configure with your server URL and API key
4. Test with a real payment
5. Monitor backend logs to verify it's working

## 📞 Support

If you encounter issues:
- Check Android Studio build output
- View logcat: `adb logcat`
- Verify Java/Android SDK versions
- Clean and rebuild project

---

**Ready to build?** Use Android Studio for the easiest experience!

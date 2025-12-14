# BDPayX SMS Monitor - Android App

## Overview
This Android app monitors incoming SMS from bKash, Nagad, and Rocket, then sends payment notifications to your server for automatic verification.

## Features
- ✅ Monitors SMS in real-time
- ✅ Detects bKash, Nagad, Rocket payments
- ✅ Sends to your server via API
- ✅ Runs in background
- ✅ Simple configuration

## Building the App

### Option 1: Android Studio (Recommended)

1. **Install Android Studio**
   - Download from: https://developer.android.com/studio

2. **Open Project**
   - Open Android Studio
   - File > Open > Select `android-sms-monitor` folder

3. **Build APK**
   - Build > Build Bundle(s) / APK(s) > Build APK(s)
   - Wait for build to complete
   - Click "locate" to find the APK file

4. **Install on Device**
   - Transfer APK to your Android phone
   - Enable "Install from Unknown Sources" in Settings
   - Install the APK

### Option 2: Command Line

```bash
cd android-sms-monitor
./gradlew assembleRelease
# APK will be in: app/build/outputs/apk/release/
```

## Configuration

1. **Open the app** on your Android device

2. **Enter Server URL**
   - Example: `https://api.bdpayx.com`
   - Must be HTTPS in production
   - Can use HTTP for local testing: `http://192.168.1.100:3000`

3. **Enter API Key**
   - Copy from your server's `.env` file
   - Look for `SMS_WEBHOOK_KEY`

4. **Grant Permissions**
   - Click "Allow" when prompted for SMS permissions
   - Required: READ_SMS, RECEIVE_SMS

5. **Verify Status**
   - Check that status shows "✓ Monitoring active"

## Testing

### Test SMS Detection

Send a test SMS to the device with this format:
```
From: bKash
Body: You have received Tk 100.00 from 01712345678. TrxID: ABC123XYZ
```

Check app logs to verify detection.

### Test Server Connection

1. Create a deposit in your app (৳100)
2. Send actual bKash payment
3. Check server logs for webhook call
4. Verify wallet balance updated

## Troubleshooting

### SMS Not Detected
- Ensure SMS permissions granted
- Check SMS is from bKash (16247), Nagad (16167), or Rocket
- View Android logs: `adb logcat | grep SmsReceiver`

### Server Not Receiving
- Verify server URL is correct (include https://)
- Check API key matches server
- Ensure device has internet connection
- Check server is accessible from device

### App Crashes
- Check Android version (minimum: Android 5.0)
- View crash logs: `adb logcat | grep AndroidRuntime`
- Reinstall the app

## File Structure

```
android-sms-monitor/
├── AndroidManifest.xml       # App configuration & permissions
├── MainActivity.java         # Main UI screen
├── SmsReceiver.java         # Receives SMS broadcasts
├── ApiService.java          # Sends data to server
├── activity_main.xml        # UI layout
├── build.gradle             # Build configuration
└── README.md               # This file
```

## Permissions Required

- **RECEIVE_SMS**: Detect incoming SMS
- **READ_SMS**: Read SMS content
- **INTERNET**: Send to server
- **ACCESS_NETWORK_STATE**: Check connectivity

## Security Notes

- API key is stored locally on device
- All communication should use HTTPS
- Only install on trusted devices
- Keep device physically secure

## Battery Optimization

To prevent Android from killing the app:

1. Go to Settings > Battery
2. Find "BDPayX Monitor"
3. Disable battery optimization
4. Allow background activity

## Production Checklist

- [ ] Built release APK (not debug)
- [ ] Installed on dedicated device
- [ ] Server URL uses HTTPS
- [ ] API key configured correctly
- [ ] SMS permissions granted
- [ ] Battery optimization disabled
- [ ] Device plugged into power
- [ ] Stable internet connection
- [ ] Tested with real payment

## Support

For issues:
1. Check app status screen
2. View Android logs: `adb logcat`
3. Check server logs
4. Verify API endpoint: `/api/sms-webhook/health`

## Version History

- **v1.0** - Initial release
  - SMS monitoring for bKash, Nagad, Rocket
  - API webhook integration
  - Simple configuration UI

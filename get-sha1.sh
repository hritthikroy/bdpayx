#!/bin/bash

# Script to get SHA-1 certificate fingerprint for Google OAuth Android setup

echo "🔐 Getting SHA-1 Certificate Fingerprint for Android"
echo "=================================================="
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ Error: keytool not found!"
    echo "   keytool comes with Java JDK"
    echo "   Install Java JDK and try again"
    exit 1
fi

echo "📱 Debug Keystore (for development):"
echo "-----------------------------------"

DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "✅ Found debug keystore at: $DEBUG_KEYSTORE"
    echo ""
    echo "SHA-1 Fingerprint:"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:" | cut -d' ' -f3
    echo ""
    echo "Full Certificate Info:"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -A 5 "Certificate fingerprints"
else
    echo "❌ Debug keystore not found at: $DEBUG_KEYSTORE"
    echo "   Run your Flutter app once to generate it:"
    echo "   flutter run"
fi

echo ""
echo "📦 Package Name:"
echo "-----------------------------------"

if [ -f "flutter_app/android/app/build.gradle.kts" ]; then
    PACKAGE_NAME=$(grep "applicationId" flutter_app/android/app/build.gradle.kts | cut -d'"' -f2)
    echo "✅ Package name: $PACKAGE_NAME"
elif [ -f "flutter_app/android/app/build.gradle" ]; then
    PACKAGE_NAME=$(grep "applicationId" flutter_app/android/app/build.gradle | cut -d'"' -f2)
    echo "✅ Package name: $PACKAGE_NAME"
else
    echo "❌ Could not find flutter_app/android/app/build.gradle or build.gradle.kts"
fi

echo ""
echo "📋 Next Steps:"
echo "-----------------------------------"
echo "1. Copy the SHA-1 fingerprint above"
echo "2. Go to: https://console.cloud.google.com/apis/credentials"
echo "3. Create Credentials → OAuth client ID → Android"
echo "4. Paste the SHA-1 and package name"
echo "5. Copy the Client ID to flutter_app/lib/config/google_config.dart"
echo ""

#!/bin/bash

echo "🚀 Building BDPayX SMS Monitor APK..."
echo ""

# Check if Android SDK is installed
if [ -z "$ANDROID_HOME" ]; then
    echo "⚠️  ANDROID_HOME not set"
    echo "Please install Android Studio or set ANDROID_HOME"
    echo ""
    echo "For macOS with Android Studio:"
    echo "export ANDROID_HOME=\$HOME/Library/Android/sdk"
    echo ""
    exit 1
fi

echo "✓ Android SDK found at: $ANDROID_HOME"
echo ""

# Make gradlew executable
chmod +x gradlew

# Clean previous builds
echo "🧹 Cleaning previous builds..."
./gradlew clean

# Build debug APK
echo ""
echo "🔨 Building debug APK..."
./gradlew assembleDebug

# Check if build was successful
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📱 APK Location:"
    echo "   $(pwd)/app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "📦 APK Size:"
    ls -lh app/build/outputs/apk/debug/app-debug.apk | awk '{print "   " $5}'
    echo ""
    echo "📲 Next Steps:"
    echo "   1. Transfer APK to your Android device"
    echo "   2. Enable 'Install from Unknown Sources'"
    echo "   3. Install the APK"
    echo "   4. Configure with your server URL and API key"
    echo ""
else
    echo ""
    echo "❌ Build failed!"
    echo "Check the error messages above"
    exit 1
fi

#!/bin/bash

echo "🚀 Android App Build Setup & Build Script"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}❌ Homebrew not found${NC}"
    echo "Please install Homebrew first:"
    echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo -e "${GREEN}✓ Homebrew found${NC}"
echo ""

# Check and install Java
echo "📦 Checking Java..."
if ! command -v java &> /dev/null; then
    echo -e "${YELLOW}Installing Java JDK 17...${NC}"
    brew install openjdk@17
    
    # Add to PATH
    echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
    export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
    
    echo -e "${GREEN}✓ Java installed${NC}"
else
    echo -e "${GREEN}✓ Java already installed${NC}"
fi

java -version
echo ""

# Check Android Studio
echo "📱 Checking Android Studio..."
if [ -d "$HOME/Library/Android/sdk" ]; then
    echo -e "${GREEN}✓ Android SDK found${NC}"
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
else
    echo -e "${YELLOW}⚠️  Android SDK not found${NC}"
    echo ""
    echo "Please install Android Studio:"
    echo "1. Download from: https://developer.android.com/studio"
    echo "2. Install Android Studio"
    echo "3. Open Android Studio and complete setup"
    echo "4. Run this script again"
    echo ""
    echo "OR use the manual build method in Android Studio:"
    echo "1. Open Android Studio"
    echo "2. File > Open > Select 'android-sms-monitor' folder"
    echo "3. Build > Build Bundle(s) / APK(s) > Build APK(s)"
    exit 1
fi

echo ""
echo "🔨 Building Android APK..."
echo ""

cd android-sms-monitor

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
    echo -e "${GREEN}=========================================="
    echo "✅ BUILD SUCCESSFUL!"
    echo "==========================================${NC}"
    echo ""
    echo "📱 APK Location:"
    echo "   $(pwd)/app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "📦 APK Size:"
    ls -lh app/build/outputs/apk/debug/app-debug.apk | awk '{print "   " $5}'
    echo ""
    echo -e "${GREEN}📲 Next Steps:${NC}"
    echo "   1. Transfer APK to your Android device"
    echo "   2. Enable 'Install from Unknown Sources' in Settings"
    echo "   3. Install the APK"
    echo "   4. Open app and configure:"
    echo "      - Server URL: https://yourdomain.com"
    echo "      - API Key: eed2e21ff245cda9ceeea36552dac08a0d5e7727058a9da0d29296b1ebb0fd65"
    echo "   5. Grant SMS permissions"
    echo "   6. Test with a small payment!"
    echo ""
else
    echo ""
    echo -e "${RED}=========================================="
    echo "❌ BUILD FAILED!"
    echo "==========================================${NC}"
    echo ""
    echo "Please check the error messages above."
    echo ""
    echo "Common solutions:"
    echo "1. Make sure Android Studio is fully installed"
    echo "2. Open Android Studio once to complete setup"
    echo "3. Try building manually in Android Studio"
    exit 1
fi

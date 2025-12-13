#!/bin/bash

echo "🚀 Starting Flutter Frontend..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo ""
    echo "📋 To install Flutter:"
    echo "   1. Visit: https://docs.flutter.dev/get-started/install"
    echo "   2. Or use Homebrew: brew install flutter"
    echo ""
    echo "📋 Alternative: Run manually in your terminal:"
    echo "   cd flutter_app"
    echo "   flutter run -d chrome --web-port=8080"
    echo ""
    exit 1
fi

# Navigate to flutter_app
cd flutter_app

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run the app
echo ""
echo "🌐 Starting Flutter web app..."
echo "   URL: http://localhost:8080"
echo "   Network: http://10.248.24.199:8080"
echo ""
flutter run -d chrome --web-port=8080

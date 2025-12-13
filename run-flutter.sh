#!/bin/bash

echo "🚀 Starting Flutter Web App..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo ""
    echo "📋 To install Flutter:"
    echo "   brew install flutter"
    echo ""
    echo "Or visit: https://docs.flutter.dev/get-started/install"
    echo ""
    exit 1
fi

# Stop the Node.js frontend server
echo "⏹️  Stopping Node.js frontend server..."
pkill -f "node serve-app-fixed.js" 2>/dev/null
pkill -f "node serve-app.js" 2>/dev/null
sleep 1

# Navigate to flutter_app
cd flutter_app

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "🌐 Starting Flutter web server..."
echo "   URL: http://localhost:8080"
echo ""
echo "💡 Hot Reload:"
echo "   Press 'r' - Hot reload"
echo "   Press 'R' - Hot restart"
echo "   Press 'q' - Quit"
echo ""

# Run Flutter
flutter run -d chrome --web-port=8080

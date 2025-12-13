#!/bin/bash

# Start Flutter Web (for development without emulator)

clear

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║              🚀 Starting BDPayX Web UI                     ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not installed!"
    echo ""
    echo "Quick install:"
    echo "  ./INSTALL_FLUTTER.sh"
    echo ""
    echo "Or manual:"
    echo "  brew install --cask flutter"
    echo ""
    exit 1
fi

# Kill old processes
pkill -f "node.*server.js" 2>/dev/null || true
pkill -f "flutter run" 2>/dev/null || true
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
sleep 1

# Start backend
echo "🔧 Starting Backend..."
cd backend
npm start > ../backend.log 2>&1 &
cd ..
sleep 3
echo "✅ Backend running on http://localhost:3000"
echo ""

# Start Flutter Web
echo "🌐 Starting Flutter Web..."
cd flutter_app
flutter pub get
flutter run -d chrome --web-port=8080 &
cd ..

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                  ✅ Web UI Starting!                       ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Flutter Web: http://localhost:8080"
echo "🔧 Backend API: http://localhost:3000"
echo ""
echo "Chrome will open automatically..."
echo ""
echo "🛑 Press Ctrl+C to stop"
echo ""

wait

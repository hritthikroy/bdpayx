#!/bin/bash

# BDPayX - Start Flutter App (Android/Web/All Platforms)
# Your original Flutter frontend + Backend

clear

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                    🚀 Starting BDPayX                      ║"
echo "║              Flutter App (All Platforms)                   ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Kill existing processes
echo "🧹 Cleaning up old processes..."
pkill -f "node.*server.js" 2>/dev/null || true
pkill -f "flutter run" 2>/dev/null || true
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
sleep 1

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found!"
    echo ""
    echo "Please install Flutter SDK:"
    echo "  brew install flutter"
    echo ""
    echo "Or visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Start Backend
echo "🔧 Starting Backend API..."
cd backend
npm start > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
sleep 3

if curl -s http://localhost:3000/api/exchange/rate > /dev/null 2>&1; then
    echo "✅ Backend running on http://localhost:3000"
else
    echo "⚠️  Backend starting..."
fi
echo ""

# Flutter setup
echo "📱 Setting up Flutter app..."
cd flutter_app
flutter pub get > /dev/null 2>&1
echo "✅ Dependencies ready"
echo ""

# Choose platform
echo "Select platform to run:"
echo "  1) Chrome (Web)"
echo "  2) Android Device/Emulator"
echo "  3) iOS Simulator (macOS only)"
echo ""
read -p "Enter choice (1-3) [default: 1]: " CHOICE
CHOICE=${CHOICE:-1}

echo ""
case $CHOICE in
    1)
        echo "🌐 Starting Flutter Web on Chrome..."
        flutter run -d chrome --web-port=8080 &
        FLUTTER_PID=$!
        ;;
    2)
        echo "📱 Starting Flutter on Android..."
        flutter run -d android &
        FLUTTER_PID=$!
        ;;
    3)
        echo "🍎 Starting Flutter on iOS..."
        flutter run -d ios &
        FLUTTER_PID=$!
        ;;
esac

cd ..

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                  ✅ Application Started!                   ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🔧 Backend API:  http://localhost:3000"
echo "📱 Flutter App:  Running on selected platform"
echo ""
echo "📊 View logs:"
echo "   Backend: tail -f backend.log"
echo ""
echo "🛑 Press Ctrl+C to stop all services"
echo ""

# Save PIDs
echo $BACKEND_PID > .backend.pid
echo $FLUTTER_PID > .flutter.pid

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $BACKEND_PID 2>/dev/null || true
    kill $FLUTTER_PID 2>/dev/null || true
    pkill -f "node.*server.js" 2>/dev/null || true
    pkill -f "flutter run" 2>/dev/null || true
    rm -f .backend.pid .flutter.pid
    echo "✅ All services stopped"
    exit 0
}

trap cleanup INT TERM

# Keep running
wait

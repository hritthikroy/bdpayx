#!/bin/bash

echo "🚀 Starting BDPayX - All Servers"
echo "================================"

# Kill existing processes
echo "🔄 Stopping existing servers..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
lsof -ti:8082 | xargs kill -9 2>/dev/null || true

sleep 2

# Start Backend
echo "⚙️  Starting Backend API (Port 3000)..."
cd backend
node src/server.js > ../backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > ../.backend.pid
cd ..

sleep 3

# Start Admin Dashboard
echo "👨‍💼 Starting Admin Dashboard (Port 8080)..."
node serve-app.js > admin.log 2>&1 &
ADMIN_PID=$!
echo $ADMIN_PID > .admin.pid

sleep 2

# Start Flutter App
echo "📱 Starting Flutter App (Port 8082)..."
cd flutter_app
flutter run -d chrome --web-port 8082 > ../flutter.log 2>&1 &
FLUTTER_PID=$!
echo $FLUTTER_PID > ../.flutter.pid
cd ..

echo ""
echo "✅ All servers started!"
echo "================================"
echo "📱 Flutter App:     http://localhost:8082"
echo "👨‍💼 Admin Panel:    http://localhost:8080"
echo "⚙️  Backend API:     http://localhost:3000"
echo "================================"
echo ""
echo "📝 Logs:"
echo "   Backend:  tail -f backend.log"
echo "   Admin:    tail -f admin.log"
echo "   Flutter:  tail -f flutter.log"
echo ""
echo "🛑 To stop all: ./STOP_ALL.sh"
echo ""
echo "⏳ Waiting for Flutter to compile (this may take 30-60 seconds)..."
echo "   The browser will open automatically when ready."

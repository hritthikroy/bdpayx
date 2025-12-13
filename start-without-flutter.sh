#!/bin/bash

# Start BDPayX without Flutter SDK
# This uses the pre-built web files or shows instructions

clear

echo "🚀 BDPayX - Starting Application"
echo "================================"
echo ""

# Kill existing processes
echo "🧹 Cleaning up..."
pkill -f "node.*server.js" 2>/dev/null || true
pkill -f "node.*serve-app" 2>/dev/null || true
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
sleep 1

# Start backend
echo "🔧 Starting Backend API..."
cd backend
npm start > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

sleep 3

# Check backend
if curl -s http://localhost:3000/api/exchange/rate > /dev/null 2>&1; then
    echo "✅ Backend running on http://localhost:3000"
else
    echo "⚠️  Backend starting..."
fi

# Start frontend server
echo "🎨 Starting Frontend Server..."
node serve-app-fixed.js > frontend.log 2>&1 &
FRONTEND_PID=$!

sleep 2

echo ""
echo "✅ Application Started!"
echo "================================"
echo ""
echo "📱 Frontend: http://localhost:8080"
echo "🔧 Backend:  http://localhost:3000"
echo ""
echo "📊 View logs:"
echo "   Backend:  tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Save PIDs
echo $BACKEND_PID > .backend.pid
echo $FRONTEND_PID > .frontend.pid

# Trap Ctrl+C
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $BACKEND_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    pkill -f "node.*server.js" 2>/dev/null || true
    rm -f .backend.pid .frontend.pid
    echo "✅ Stopped"
    exit 0
}

trap cleanup INT TERM

# Keep running
wait

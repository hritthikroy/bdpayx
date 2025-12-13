#!/bin/bash

# BDPayX - One-Click Startup Script
# Starts both backend and clean UI frontend

clear

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                    🚀 Starting BDPayX                      ║"
echo "║              BDT to INR Currency Exchange                  ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Kill existing processes
echo "🧹 Cleaning up old processes..."
pkill -f "node.*server.js" 2>/dev/null || true
pkill -f "node.*serve-web-ui" 2>/dev/null || true
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
    echo "✅ Backend running"
else
    echo "⚠️  Backend starting..."
fi

# Start frontend
echo "🎨 Starting Clean UI..."
node serve-web-ui.js > frontend.log 2>&1 &
FRONTEND_PID=$!
sleep 2

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                  ✅ Application Started!                   ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📱 Open in browser: http://localhost:8080"
echo "🔧 Backend API:     http://localhost:3000"
echo ""
echo "✨ Features:"
echo "   • Modern gradient UI design"
echo "   • Live exchange rates"
echo "   • Real-time calculator"
echo "   • Secure authentication"
echo "   • Responsive layout"
echo ""
echo "📊 View logs:"
echo "   Backend:  tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "🛑 Press Ctrl+C to stop all services"
echo ""

# Save PIDs
echo $BACKEND_PID > .backend.pid
echo $FRONTEND_PID > .frontend.pid

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $BACKEND_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    pkill -f "node.*server.js" 2>/dev/null || true
    pkill -f "node.*serve-web-ui" 2>/dev/null || true
    rm -f .backend.pid .frontend.pid
    echo "✅ All services stopped"
    exit 0
}

trap cleanup INT TERM

# Keep running
wait

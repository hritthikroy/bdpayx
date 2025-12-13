#!/bin/bash

# Start BDPayX with Admin Dashboard

clear

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║              🔐 BDPayX Admin System                        ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Kill old processes
pkill -f "node.*server.js" 2>/dev/null || true
pkill -f "http-server" 2>/dev/null || true
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
lsof -ti:8081 | xargs kill -9 2>/dev/null || true
sleep 1

# Start backend
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

# Start admin dashboard
echo "🔐 Starting Admin Dashboard..."
if command -v http-server &> /dev/null; then
    cd admin-dashboard
    http-server -p 8081 > ../admin.log 2>&1 &
    ADMIN_PID=$!
    cd ..
    echo "✅ Admin Dashboard running on http://localhost:8081"
else
    echo "⚠️  http-server not found. Installing..."
    npm install -g http-server
    cd admin-dashboard
    http-server -p 8081 > ../admin.log 2>&1 &
    ADMIN_PID=$!
    cd ..
    echo "✅ Admin Dashboard running on http://localhost:8081"
fi
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                  ✅ System Started!                        ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🔐 Admin Dashboard: http://localhost:8081"
echo "🔧 Backend API:     http://localhost:3000"
echo ""
echo "📋 Admin Features:"
echo "   • Real-time monitoring"
echo "   • User management"
echo "   • Transaction control"
echo "   • KYC approval"
echo "   • Exchange rate updates"
echo "   • Notifications & announcements"
echo "   • Analytics & reports"
echo "   • Activity logs"
echo ""
echo "🔑 Default Admin Login:"
echo "   Phone: +8801700000000"
echo "   Password: admin123"
echo "   (Change this immediately!)"
echo ""
echo "📊 View logs:"
echo "   Backend: tail -f backend.log"
echo "   Admin:   tail -f admin.log"
echo ""
echo "🛑 Press Ctrl+C to stop all services"
echo ""

# Save PIDs
echo $BACKEND_PID > .backend.pid
echo $ADMIN_PID > .admin.pid

# Cleanup
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $BACKEND_PID 2>/dev/null || true
    kill $ADMIN_PID 2>/dev/null || true
    pkill -f "node.*server.js" 2>/dev/null || true
    pkill -f "http-server" 2>/dev/null || true
    rm -f .backend.pid .admin.pid
    echo "✅ All services stopped"
    exit 0
}

trap cleanup INT TERM

wait

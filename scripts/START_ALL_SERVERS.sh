#!/bin/bash

echo "🚀 Starting All BDPayX Servers..."
echo ""

# Check if servers are already running
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Port 3000 already in use (Admin Panel)"
else
    echo "Starting Admin Panel on port 3000..."
fi

if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Port 8080 already in use (Frontend)"
else
    echo "Starting Frontend on port 8080..."
fi

if lsof -Pi :8081 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Port 8081 already in use (Backend)"
else
    echo "Starting Backend on port 8081..."
fi

echo ""
echo "✅ All servers should be running!"
echo ""
echo "📱 Admin Panel:  http://localhost:3000"
echo "📱 Frontend:     http://localhost:8080/#/main"
echo "📱 Backend API:  http://localhost:8081/api/exchange/rate"
echo ""
echo "🔐 Admin Login: admin@bdpayx.com / admin123"
echo ""

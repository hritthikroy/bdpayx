#!/bin/bash

echo "🛑 Stopping BDPayX - All Servers"
echo "================================"

# Kill by port
echo "Stopping Backend (Port 3000)..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true

echo "Stopping Admin (Port 8080)..."
lsof -ti:8080 | xargs kill -9 2>/dev/null || true

echo "Stopping Flutter (Port 8082)..."
lsof -ti:8082 | xargs kill -9 2>/dev/null || true

# Kill by PID files
if [ -f .backend.pid ]; then
    kill -9 $(cat .backend.pid) 2>/dev/null || true
    rm .backend.pid
fi

if [ -f .admin.pid ]; then
    kill -9 $(cat .admin.pid) 2>/dev/null || true
    rm .admin.pid
fi

if [ -f .flutter.pid ]; then
    kill -9 $(cat .flutter.pid) 2>/dev/null || true
    rm .flutter.pid
fi

echo ""
echo "✅ All servers stopped!"
echo "================================"

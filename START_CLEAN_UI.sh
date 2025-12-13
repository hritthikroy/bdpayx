#!/bin/bash

# BDPayX - Clean UI Startup Script
# This script starts both backend and frontend with a clean UI

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Clear screen
clear

echo -e "${PURPLE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                    🚀 BDPayX Launcher                      ║"
echo "║              BDT to INR Currency Exchange                  ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Step 1: Check Flutter installation
echo -e "${CYAN}[1/5] Checking Flutter installation...${NC}"
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
    echo -e "${GREEN}✅ Flutter found: $FLUTTER_VERSION${NC}"
    FLUTTER_AVAILABLE=true
else
    echo -e "${YELLOW}⚠️  Flutter not found${NC}"
    echo -e "${YELLOW}    You can install it with: brew install flutter${NC}"
    FLUTTER_AVAILABLE=false
fi
echo ""

# Step 2: Check Node.js
echo -e "${CYAN}[2/5] Checking Node.js...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js found: $NODE_VERSION${NC}"
else
    echo -e "${RED}❌ Node.js not found. Please install Node.js first.${NC}"
    exit 1
fi
echo ""

# Step 3: Install backend dependencies
echo -e "${CYAN}[3/5] Checking backend dependencies...${NC}"
if [ ! -d "backend/node_modules" ]; then
    echo -e "${YELLOW}📦 Installing backend dependencies...${NC}"
    cd backend && npm install && cd ..
    echo -e "${GREEN}✅ Backend dependencies installed${NC}"
else
    echo -e "${GREEN}✅ Backend dependencies already installed${NC}"
fi
echo ""

# Step 4: Kill existing processes
echo -e "${CYAN}[4/5] Cleaning up existing processes...${NC}"
pkill -f "node.*server.js" 2>/dev/null || true
pkill -f "node.*serve-app" 2>/dev/null || true
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
sleep 1
echo -e "${GREEN}✅ Ports 3000 and 8080 are now available${NC}"
echo ""

# Step 5: Start services
echo -e "${CYAN}[5/5] Starting services...${NC}"
echo ""

# Start backend
echo -e "${BLUE}🔧 Starting Backend API Server...${NC}"
cd backend
npm start > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
sleep 2

# Check if backend started successfully
if curl -s http://localhost:3000/api/exchange/rate > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend API running on http://localhost:3000${NC}"
else
    echo -e "${YELLOW}⚠️  Backend starting... (may take a few more seconds)${NC}"
fi
echo ""

# Start frontend based on Flutter availability
if [ "$FLUTTER_AVAILABLE" = true ]; then
    echo -e "${BLUE}🎨 Choose Frontend Mode:${NC}"
    echo "  1) Development Mode (Hot Reload, Recommended)"
    echo "  2) Production Build (Optimized)"
    echo "  3) Simple Server (Current build)"
    echo ""
    read -p "Enter choice (1-3) [default: 1]: " CHOICE
    CHOICE=${CHOICE:-1}
    
    case $CHOICE in
        1)
            echo -e "${BLUE}🎨 Starting Flutter Development Server...${NC}"
            echo -e "${YELLOW}   This will open Chrome automatically${NC}"
            cd flutter_app
            flutter pub get > /dev/null 2>&1
            flutter run -d chrome --web-port=8080 &
            FLUTTER_PID=$!
            cd ..
            ;;
        2)
            echo -e "${BLUE}🎨 Building Flutter for Production...${NC}"
            cd flutter_app
            flutter pub get
            flutter build web --release
            cd ..
            echo -e "${GREEN}✅ Build complete${NC}"
            echo -e "${BLUE}🎨 Starting Production Server...${NC}"
            node serve-app-fixed.js > frontend.log 2>&1 &
            FLUTTER_PID=$!
            ;;
        3)
            echo -e "${BLUE}🎨 Starting Simple Server...${NC}"
            node serve-app-fixed.js > frontend.log 2>&1 &
            FLUTTER_PID=$!
            ;;
    esac
else
    echo -e "${BLUE}🎨 Starting Simple Server...${NC}"
    node serve-app-fixed.js > frontend.log 2>&1 &
    FLUTTER_PID=$!
fi

sleep 2
echo ""

# Display success message
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                  ✅ Application Started!                   ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${CYAN}📱 Access your application:${NC}"
echo ""
echo -e "   🌐 Frontend:  ${GREEN}http://localhost:8080${NC}"
echo -e "   🔧 Backend:   ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "${CYAN}📊 Logs:${NC}"
echo -e "   Backend:  tail -f backend.log"
echo -e "   Frontend: tail -f frontend.log"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
echo ""

# Save PIDs for cleanup
echo $BACKEND_PID > .backend.pid
echo $FLUTTER_PID > .frontend.pid

# Trap Ctrl+C
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Stopping services...${NC}"
    kill $BACKEND_PID 2>/dev/null || true
    kill $FLUTTER_PID 2>/dev/null || true
    pkill -f "node.*server.js" 2>/dev/null || true
    pkill -f "flutter run" 2>/dev/null || true
    rm -f .backend.pid .frontend.pid
    echo -e "${GREEN}✅ All services stopped${NC}"
    exit 0
}

trap cleanup INT TERM

# Keep script running
wait

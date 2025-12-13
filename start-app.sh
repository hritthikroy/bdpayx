#!/bin/bash

echo "🚀 Starting BDPayX Application..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backend dependencies are installed
if [ ! -d "backend/node_modules" ]; then
    echo -e "${YELLOW}📦 Installing backend dependencies...${NC}"
    cd backend && npm install && cd ..
fi

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  Flutter not found. Please install Flutter SDK first.${NC}"
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Clean Flutter build
echo -e "${BLUE}🧹 Cleaning Flutter build...${NC}"
cd flutter_app
flutter clean
flutter pub get
cd ..

# Kill any existing processes on ports 3000 and 8080
echo -e "${BLUE}🔍 Checking for existing processes...${NC}"
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8080 | xargs kill -9 2>/dev/null || true

# Start backend server
echo -e "${GREEN}🔧 Starting backend server on port 3000...${NC}"
cd backend
npm start &
BACKEND_PID=$!
cd ..

# Wait for backend to start
sleep 3

# Start Flutter web app
echo -e "${GREEN}🎨 Starting Flutter web app on port 8080...${NC}"
cd flutter_app
flutter run -d chrome --web-port=8080 --web-hostname=localhost &
FLUTTER_PID=$!
cd ..

echo ""
echo -e "${GREEN}✅ Application started successfully!${NC}"
echo ""
echo "📱 Frontend: http://localhost:8080"
echo "🔧 Backend API: http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for user interrupt
trap "kill $BACKEND_PID $FLUTTER_PID 2>/dev/null; exit" INT
wait

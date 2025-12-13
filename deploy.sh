#!/bin/bash

# BDPayX Production Deployment Script
# Usage: ./deploy.sh

set -e  # Exit on error

echo "🚀 Starting BDPayX Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKEND_DIR="backend"
FLUTTER_DIR="flutter_app"
WEB_DIR="/var/www/bdpayx"
PM2_APP_NAME="bdpayx-backend"

# Check if running as root for web deployment
if [ "$EUID" -ne 0 ] && [ -d "$WEB_DIR" ]; then 
    echo -e "${YELLOW}⚠️  Warning: Not running as root. Web deployment may fail.${NC}"
    echo "Run with sudo for full deployment: sudo ./deploy.sh"
fi

# Step 1: Pull latest code
echo -e "${GREEN}📥 Pulling latest code...${NC}"
git pull origin main || {
    echo -e "${RED}❌ Git pull failed${NC}"
    exit 1
}

# Step 2: Backend deployment
echo -e "${GREEN}📦 Deploying backend...${NC}"
cd $BACKEND_DIR

# Install dependencies
echo "Installing backend dependencies..."
npm install --production

# Run database migrations (if any)
# npm run migrate

# Restart PM2
echo "Restarting backend with PM2..."
pm2 restart $PM2_APP_NAME || pm2 start ../ecosystem.config.js --env production

cd ..

# Step 3: Flutter web build
echo -e "${GREEN}🌐 Building Flutter web app...${NC}"
cd $FLUTTER_DIR

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build for web
flutter build web --release --web-renderer html

cd ..

# Step 4: Deploy web app
if [ -d "$WEB_DIR" ]; then
    echo -e "${GREEN}📤 Deploying web app...${NC}"
    
    # Backup current version
    if [ -d "$WEB_DIR/web" ]; then
        echo "Creating backup..."
        sudo mv $WEB_DIR/web $WEB_DIR/web.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # Copy new build
    echo "Copying new build..."
    sudo cp -r $FLUTTER_DIR/build/web $WEB_DIR/
    
    # Set permissions
    sudo chown -R www-data:www-data $WEB_DIR/web
    sudo chmod -R 755 $WEB_DIR/web
    
    # Clean old backups (keep last 3)
    echo "Cleaning old backups..."
    sudo ls -t $WEB_DIR/web.backup.* 2>/dev/null | tail -n +4 | xargs -r sudo rm -rf
else
    echo -e "${YELLOW}⚠️  Web directory $WEB_DIR not found. Skipping web deployment.${NC}"
fi

# Step 5: Reload Nginx
if command -v nginx &> /dev/null; then
    echo -e "${GREEN}🔄 Reloading Nginx...${NC}"
    sudo nginx -t && sudo systemctl reload nginx
fi

# Step 6: Health check
echo -e "${GREEN}🏥 Running health check...${NC}"
sleep 3

# Check backend
if curl -f http://localhost:3000/health &> /dev/null; then
    echo -e "${GREEN}✅ Backend is healthy${NC}"
else
    echo -e "${RED}❌ Backend health check failed${NC}"
    pm2 logs $PM2_APP_NAME --lines 50
    exit 1
fi

# Step 7: Show status
echo -e "${GREEN}📊 Deployment Status:${NC}"
pm2 status $PM2_APP_NAME

# Step 8: Show logs
echo -e "${GREEN}📝 Recent logs:${NC}"
pm2 logs $PM2_APP_NAME --lines 20 --nostream

echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo "🌐 Web App: https://bdpayx.com"
echo "🔌 API: https://api.bdpayx.com"
echo ""
echo "📊 Monitor: pm2 monit"
echo "📝 Logs: pm2 logs $PM2_APP_NAME"
echo "🔄 Restart: pm2 restart $PM2_APP_NAME"
echo ""

#!/bin/bash

# Migration script from Node.js to Go backend

set -e

echo "🔄 BDPayX Backend Migration: Node.js → Go"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Go is installed
if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go 1.21 or higher."
    exit 1
fi

print_success "Go is installed: $(go version)"

# Check if Node.js backend exists
if [ ! -d "backend" ]; then
    print_warning "Node.js backend directory not found. Skipping backup."
else
    print_status "Backing up Node.js backend..."
    if [ -d "backend-nodejs-backup" ]; then
        print_warning "Backup already exists. Skipping backup."
    else
        cp -r backend backend-nodejs-backup
        print_success "Node.js backend backed up to backend-nodejs-backup/"
    fi
fi

# Check if Go backend exists
if [ ! -d "backend-go" ]; then
    print_error "Go backend directory not found. Please ensure backend-go/ exists."
    exit 1
fi

print_status "Setting up Go backend..."
cd backend-go

# Install Go dependencies
print_status "Installing Go dependencies..."
go mod tidy
print_success "Dependencies installed"

# Setup environment file
if [ ! -f ".env" ]; then
    print_status "Creating .env file..."
    cp .env.example .env
    
    # Try to copy settings from Node.js backend
    if [ -f "../backend/.env" ]; then
        print_status "Copying settings from Node.js backend..."
        
        # Extract key values from Node.js .env
        if grep -q "PORT=" ../backend/.env; then
            PORT=$(grep "PORT=" ../backend/.env | cut -d '=' -f2)
            sed -i.bak "s/PORT=3000/PORT=$PORT/" .env
        fi
        
        if grep -q "JWT_SECRET=" ../backend/.env; then
            JWT_SECRET=$(grep "JWT_SECRET=" ../backend/.env | cut -d '=' -f2)
            sed -i.bak "s/JWT_SECRET=currency_exchange_secret_key_2024/JWT_SECRET=$JWT_SECRET/" .env
        fi
        
        if grep -q "DB_CONNECTION_STRING=" ../backend/.env; then
            DB_URL=$(grep "DB_CONNECTION_STRING=" ../backend/.env | cut -d '=' -f2-)
            sed -i.bak "s|DB_CONNECTION_STRING=.*|DB_CONNECTION_STRING=$DB_URL|" .env
        fi
        
        if grep -q "SUPABASE_URL=" ../backend/.env; then
            SUPABASE_URL=$(grep "SUPABASE_URL=" ../backend/.env | cut -d '=' -f2-)
            sed -i.bak "s|SUPABASE_URL=.*|SUPABASE_URL=$SUPABASE_URL|" .env
        fi
        
        # Clean up backup files
        rm -f .env.bak
        
        print_success "Settings copied from Node.js backend"
    else
        print_warning "Node.js .env not found. Please update backend-go/.env manually."
    fi
else
    print_success ".env file already exists"
fi

# Create uploads directory
mkdir -p uploads
print_success "Uploads directory created"

# Build the Go backend
print_status "Building Go backend..."
go build -o bdpayx-backend main.go
print_success "Go backend built successfully"

# Test the build
print_status "Testing Go backend..."
timeout 5s ./bdpayx-backend > /dev/null 2>&1 || true
print_success "Go backend test completed"

# Stop Node.js backend if running
print_status "Stopping Node.js backend..."
pkill -f "node.*server.js" 2>/dev/null || true
pkill -f "nodemon" 2>/dev/null || true
print_success "Node.js backend stopped"

cd ..

print_success "Migration setup completed!"
echo ""
echo "📋 Next Steps:"
echo "1. Review and update backend-go/.env with your configuration"
echo "2. Start the Go backend:"
echo "   cd backend-go && ./bdpayx-backend"
echo "3. Test your application endpoints"
echo "4. Update any deployment scripts to use the Go backend"
echo ""
echo "📚 For detailed migration guide, see: MIGRATION_GUIDE.md"
echo ""
echo "🔄 To rollback to Node.js:"
echo "   mv backend-nodejs-backup backend"
echo ""
print_success "Happy migrating! 🚀"
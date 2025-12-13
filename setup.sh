#!/bin/bash

echo "🚀 Currency Exchange App Setup"
echo "================================"

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed. Please install it first:"
    echo "   macOS: brew install postgresql@14"
    echo "   Linux: sudo apt install postgresql"
    exit 1
fi

# Check if Redis is installed
if ! command -v redis-cli &> /dev/null; then
    echo "❌ Redis is not installed. Please install it first:"
    echo "   macOS: brew install redis"
    echo "   Linux: sudo apt install redis-server"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install it first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install it first."
    exit 1
fi

echo "✅ All prerequisites are installed"
echo ""

# Setup Backend
echo "📦 Setting up backend..."
cd backend

# Install npm packages
echo "Installing npm packages..."
npm install

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please edit backend/.env and update DB_PASSWORD and JWT_SECRET"
fi

# Create uploads directory
mkdir -p uploads/payment-proofs
echo "✅ Backend setup complete"
echo ""

# Setup Database
echo "🗄️  Setting up database..."
read -p "Enter PostgreSQL username (default: postgres): " DB_USER
DB_USER=${DB_USER:-postgres}

read -sp "Enter PostgreSQL password: " DB_PASSWORD
echo ""

# Create database
echo "Creating database..."
PGPASSWORD=$DB_PASSWORD createdb -U $DB_USER currency_exchange 2>/dev/null || echo "Database might already exist"

# Run schema
echo "Running database schema..."
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER currency_exchange < src/database/schema.sql

echo "✅ Database setup complete"
echo ""

cd ..

# Setup Flutter
echo "📱 Setting up Flutter app..."
cd flutter_app

echo "Getting Flutter dependencies..."
flutter pub get

echo "✅ Flutter setup complete"
echo ""

cd ..

echo "================================"
echo "✅ Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Edit backend/.env file with your credentials"
echo "2. Start backend: cd backend && npm run dev"
echo "3. Start Flutter app (in new terminal): cd flutter_app && flutter run"
echo ""
echo "Happy coding! 🎉"

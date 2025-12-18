#!/bin/bash

# Start script for BDPayX Go Backend

echo "🚀 Starting BDPayX Go Backend..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Copying from .env.example..."
    cp .env.example .env
    echo "📝 Please update .env file with your configuration"
fi

# Create uploads directory if it doesn't exist
mkdir -p uploads

# Check if binary exists
if [ ! -f bdpayx-backend ]; then
    echo "🔨 Binary not found. Building..."
    go build -o bdpayx-backend main.go
fi

# Start the server
echo "🌟 Starting server..."
./bdpayx-backend
#!/bin/bash

# Build script for BDPayX Go Backend

echo "🔨 Building BDPayX Go Backend..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -f bdpayx-backend

# Download dependencies
echo "📦 Downloading dependencies..."
go mod tidy

# Run tests
echo "🧪 Running tests..."
go test ./...

# Build for current platform
echo "🏗️  Building for current platform..."
go build -ldflags="-s -w" -o bdpayx-backend main.go

# Build for Linux (production)
echo "🐧 Building for Linux..."
GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bdpayx-backend-linux main.go

# Build for Windows
echo "🪟 Building for Windows..."
GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o bdpayx-backend.exe main.go

echo "✅ Build complete!"
echo "📁 Binaries created:"
echo "   - bdpayx-backend (current platform)"
echo "   - bdpayx-backend-linux (Linux)"
echo "   - bdpayx-backend.exe (Windows)"
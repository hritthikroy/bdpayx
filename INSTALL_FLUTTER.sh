#!/bin/bash

# Quick Flutter Installation for macOS

echo "📦 Installing Flutter SDK..."
echo ""

# Install Flutter via Homebrew
brew install --cask flutter

# Add to PATH (if needed)
echo ""
echo "🔧 Setting up Flutter..."
flutter doctor

echo ""
echo "✅ Flutter installed!"
echo ""
echo "Now run: ./START_APP.sh"

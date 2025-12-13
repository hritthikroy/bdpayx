#!/bin/bash

echo "🧹 Clearing Flutter cache..."

# Navigate to flutter_app directory
cd flutter_app

# Clean Flutter build cache
echo "Cleaning build cache..."
rm -rf build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# Clear pub cache
echo "Clearing pub cache..."
rm -rf ~/.pub-cache/hosted/pub.dartlang.org/

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Clean and rebuild
echo "Running flutter clean..."
flutter clean

echo ""
echo "✅ Cache cleared successfully!"
echo ""
echo "🚀 To restart the app, run:"
echo "   flutter run -d chrome"
echo ""
echo "Or for hot reload:"
echo "   flutter run -d chrome --hot"

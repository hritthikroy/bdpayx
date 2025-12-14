#!/bin/bash

echo "🔧 Fixing Flutter Icons Issue - Complete Solution"
echo ""

cd flutter_app

# Clean build cache
echo "1️⃣ Cleaning Flutter build cache..."
flutter clean

# Get dependencies
echo ""
echo "2️⃣ Getting Flutter dependencies..."
flutter pub get

# Build for web with FULL icon font (no tree-shaking)
echo ""
echo "3️⃣ Building Flutter web app with FULL Material Icons font..."
echo "   (Using --no-tree-shake-icons to include all icons)"
flutter build web --release --no-tree-shake-icons

cd ..

echo ""
echo "✅ Icon fix complete!"
echo ""
echo "📊 Icon font size: ~1.6MB (full icon set included)"
echo ""
echo "📱 To test the app:"
echo "   1. Run: node serve-app.js"
echo "   2. Open: http://localhost:8080"
echo ""
echo "🔄 If icons still don't show:"
echo "   - Clear browser cache completely (Cmd+Shift+Delete)"
echo "   - Hard refresh (Cmd+Shift+R or Ctrl+Shift+R)"
echo "   - Try incognito/private mode"
echo "   - Check browser console (F12) for errors"
echo ""

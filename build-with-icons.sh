#!/bin/bash

echo "🚀 Building Flutter Web with Icon Fix"
echo "======================================"
echo ""

cd flutter_app

# Step 1: Clean
echo "1️⃣ Cleaning previous build..."
flutter clean
echo ""

# Step 2: Get dependencies
echo "2️⃣ Getting dependencies..."
flutter pub get
echo ""

# Step 3: Build with full icons
echo "3️⃣ Building for web (with full icon set)..."
flutter build web --release --no-tree-shake-icons
echo ""

cd ..

# Step 4: Fix FontManifest.json
echo "4️⃣ Fixing FontManifest.json..."
node fix-font-manifest.js
echo ""

# Step 5: Verify
echo "5️⃣ Verifying build..."
echo ""

# Check font file
if [ -f "flutter_app/build/web/assets/fonts/MaterialIcons-Regular.otf" ]; then
    SIZE=$(ls -lh flutter_app/build/web/assets/fonts/MaterialIcons-Regular.otf | awk '{print $5}')
    echo "✅ Icon font file: $SIZE"
else
    echo "❌ Icon font file missing!"
fi

# Check FontManifest
if grep -q "MaterialIcons" flutter_app/build/web/assets/FontManifest.json; then
    echo "✅ FontManifest.json includes MaterialIcons"
else
    echo "❌ FontManifest.json missing MaterialIcons!"
fi

echo ""
echo "======================================"
echo "✅ Build complete!"
echo ""
echo "🌐 To test:"
echo "   node serve-no-cache.js"
echo "   Open: http://localhost:8081"
echo ""

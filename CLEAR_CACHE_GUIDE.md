# 🧹 Clear Cache & Restart Flutter App

## Quick Commands

### Option 1: Use the Script (Recommended)
```bash
./restart-flutter.sh
```

### Option 2: Manual Commands
```bash
# Navigate to flutter app
cd flutter_app

# Clear all cache
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# Get dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

### Option 3: Deep Clean (If issues persist)
```bash
cd flutter_app

# Clear Flutter cache
flutter clean

# Clear pub cache
flutter pub cache clean

# Remove all build artifacts
rm -rf build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
rm -rf .packages

# Get dependencies fresh
flutter pub get

# Run the app
flutter run -d chrome
```

---

## 🔄 Restart Backend

```bash
cd backend

# Stop any running processes
pkill -f "node src/server.js"

# Clear node_modules cache (optional)
rm -rf node_modules
npm install

# Restart server
npm run dev
```

---

## 🌐 Clear Browser Cache

### Chrome:
1. Press `Cmd + Shift + Delete` (Mac) or `Ctrl + Shift + Delete` (Windows)
2. Select "Cached images and files"
3. Click "Clear data"

### Or Hard Reload:
- `Cmd + Shift + R` (Mac)
- `Ctrl + Shift + R` (Windows)

---

## 🚀 Full Restart Process

```bash
# 1. Clear Flutter cache
cd flutter_app
flutter clean
rm -rf build/ .dart_tool/
flutter pub get

# 2. Restart backend
cd ../backend
pkill -f "node src/server.js"
npm run dev

# 3. Run Flutter app
cd ../flutter_app
flutter run -d chrome
```

---

## ⚡ Hot Reload (Faster)

If app is already running:
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

---

## 🐛 Troubleshooting

### Issue: "Flutter command not found"
**Solution:**
```bash
# Check if Flutter is installed
which flutter

# If not found, install Flutter:
# https://docs.flutter.dev/get-started/install
```

### Issue: "Pub get failed"
**Solution:**
```bash
flutter pub cache clean
flutter pub get
```

### Issue: "Build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter run -d chrome --verbose
```

### Issue: "Port already in use"
**Solution:**
```bash
# Kill process on port 3000 (backend)
lsof -ti:3000 | xargs kill -9

# Kill process on port 8080 (flutter)
lsof -ti:8080 | xargs kill -9
```

---

## 📝 Quick Reference

| Command | Purpose |
|---------|---------|
| `flutter clean` | Remove build cache |
| `flutter pub get` | Get dependencies |
| `flutter run -d chrome` | Run on Chrome |
| `flutter run -d chrome --hot` | Run with hot reload |
| `r` | Hot reload (in running app) |
| `R` | Hot restart (in running app) |
| `q` | Quit app |

---

## ✅ After Clearing Cache

Your app should now:
- ✅ Load with updated UI changes
- ✅ Show modern gradient designs
- ✅ Display updated transactions screen
- ✅ Show new profile screen layout
- ✅ Work without any cache issues

---

**🎉 Enjoy your updated app!**

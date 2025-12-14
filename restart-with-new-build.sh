#!/bin/bash

echo "🔄 Restarting Flutter app with new build..."

# Kill existing Flutter process if running
if [ -f .flutter.pid ]; then
    FLUTTER_PID=$(cat .flutter.pid)
    if ps -p $FLUTTER_PID > /dev/null 2>&1; then
        echo "Stopping existing Flutter process (PID: $FLUTTER_PID)..."
        kill $FLUTTER_PID 2>/dev/null || true
        sleep 2
    fi
    rm .flutter.pid
fi

# Start the Flutter web server
echo "Starting Flutter web server on port 8080..."
cd flutter_app/build/web
python3 -m http.server 8080 &
FLUTTER_PID=$!
cd ../../..
echo $FLUTTER_PID > .flutter.pid

echo "✅ Flutter app restarted!"
echo "📱 Access at: http://localhost:8080"
echo ""
echo "The Noto fonts have been added to fix the font warnings."
echo "Clear your browser cache (Ctrl+Shift+R or Cmd+Shift+R) to see the changes."

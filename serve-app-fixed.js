const express = require('express');
const path = require('path');
const cors = require('cors');
const fs = require('fs');

const app = express();
const PORT = 8080;

// Enable CORS
app.use(cors());

// Check which folder to serve from
const buildPath = path.join(__dirname, 'flutter_app', 'build', 'web');
const webPath = path.join(__dirname, 'flutter_app', 'web');

let servePath;
let isBuilt = false;

if (fs.existsSync(buildPath)) {
  servePath = buildPath;
  isBuilt = true;
  console.log('✅ Serving from: flutter_app/build/web (Built version)');
} else {
  servePath = webPath;
  console.log('⚠️  Serving from: flutter_app/web (Template only - needs build)');
}

// Serve static files
app.use(express.static(servePath));

// Fallback route
app.use((req, res) => {
  if (!isBuilt) {
    // Show helpful error page if not built
    res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Flutter App Not Built</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 50%, #A855F7 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
          }
          .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          }
          h1 { color: #6366F1; margin-bottom: 20px; }
          h2 { color: #1E293B; margin: 30px 0 15px; font-size: 20px; }
          p { color: #64748B; line-height: 1.6; margin-bottom: 15px; }
          code {
            background: #F1F5F9;
            padding: 2px 8px;
            border-radius: 4px;
            font-family: 'Monaco', 'Courier New', monospace;
            color: #EF4444;
          }
          .command {
            background: #1E293B;
            color: #10B981;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            font-family: 'Monaco', 'Courier New', monospace;
            overflow-x: auto;
          }
          .warning {
            background: #FEF3C7;
            border-left: 4px solid #F59E0B;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
          }
          .success {
            background: #D1FAE5;
            border-left: 4px solid #10B981;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
          }
          ul { margin-left: 20px; color: #64748B; }
          li { margin: 8px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🔧 Flutter App Needs to be Built</h1>
          
          <div class="warning">
            <strong>⚠️ Issue:</strong> The Flutter web app hasn't been compiled yet.
          </div>
          
          <h2>✅ Solution:</h2>
          
          <p><strong>Option 1: Build the app (Recommended for production)</strong></p>
          <div class="command">
cd flutter_app<br>
flutter build web --release<br>
cd ..<br>
node serve-app-fixed.js
          </div>
          
          <p><strong>Option 2: Run Flutter dev server (Recommended for development)</strong></p>
          <div class="command">
cd flutter_app<br>
flutter run -d chrome --web-port=8080
          </div>
          
          <div class="success">
            <strong>💡 Tip:</strong> Option 2 gives you hot reload - changes appear instantly!
          </div>
          
          <h2>📋 What's Happening:</h2>
          <ul>
            <li>✅ Backend is running on port 3000</li>
            <li>✅ Frontend server is running on port 8080</li>
            <li>❌ Flutter app is not compiled yet</li>
            <li>❌ Missing: <code>flutter_bootstrap.js</code> and other files</li>
          </ul>
          
          <h2>🔍 Check Flutter Installation:</h2>
          <div class="command">
flutter --version<br>
flutter doctor
          </div>
          
          <p>If Flutter is not installed:</p>
          <div class="command">
brew install flutter
          </div>
          
          <p style="margin-top: 30px; text-align: center; color: #94A3B8;">
            <strong>Backend API:</strong> <a href="http://localhost:3000" style="color: #6366F1;">http://localhost:3000</a>
          </p>
        </div>
      </body>
      </html>
    `);
  } else {
    res.sendFile(path.join(servePath, 'index.html'));
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('🎉 Frontend Server Started!');
  console.log('================================');
  console.log(`📱 Local:    http://localhost:${PORT}`);
  console.log(`🌐 Network:  http://10.248.24.199:${PORT}`);
  console.log('================================');
  console.log('');
  
  if (!isBuilt) {
    console.log('⚠️  WARNING: Flutter app not built!');
    console.log('');
    console.log('To fix:');
    console.log('  cd flutter_app');
    console.log('  flutter build web');
    console.log('');
    console.log('Or run dev server:');
    console.log('  cd flutter_app');
    console.log('  flutter run -d chrome --web-port=8080');
    console.log('');
  } else {
    console.log('✅ Serving built Flutter app');
    console.log('');
  }
  
  console.log('✅ Backend API: http://localhost:3000');
  console.log('✅ Frontend:    http://localhost:8080');
  console.log('');
  console.log('Press Ctrl+C to stop');
  console.log('');
});

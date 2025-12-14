const express = require('express');
const path = require('path');

const app = express();
const PORT = 8081; // Different port to avoid conflicts

// Disable all caching
app.use((req, res, next) => {
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');
  res.setHeader('Surrogate-Control', 'no-store');
  next();
});

// Serve Flutter web build
app.use(express.static(path.join(__dirname, 'flutter_app/build/web'), {
  etag: false,
  lastModified: false,
  maxAge: 0
}));

app.listen(PORT, '0.0.0.0', () => {
  console.log('\n🚀 NO-CACHE Frontend Server Started!');
  console.log('================================');
  console.log(`📱 Local:    http://localhost:${PORT}`);
  console.log('================================');
  console.log('✅ All caching DISABLED');
  console.log('✅ Fresh load every time');
  console.log('✅ Perfect for testing icon fix');
  console.log('\n💡 This server bypasses ALL cache');
  console.log('   Use this to verify icons work!\n');
  console.log('Press Ctrl+C to stop\n');
});

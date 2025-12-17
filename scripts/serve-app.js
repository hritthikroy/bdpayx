const express = require('express');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 8080;

// Enable CORS
app.use(cors());

// Special handling for font files to ensure proper MIME types and caching
app.get(/.(woff|woff2|ttf|eot|otf)$/, (req, res, next) => {
  // Set proper headers for font files
  res.setHeader('Content-Type', 'font/otf');
  res.setHeader('Cache-Control', 'public, max-age=31536000'); // Cache fonts for 1 year
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

// Disable caching for HTML, JS, CSS, but keep caching for fonts
app.use((req, res, next) => {
  // Don't cache HTML, JS, CSS, or other dynamic content
  if (!req.url.match(/\.(woff|woff2|ttf|eot|otf)$/)) {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-validate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    res.setHeader('Surrogate-Control', 'no-store');
  }
  next();
});

// Serve static files from Flutter web directory
const webPath = path.join(__dirname, '..', 'flutter_app', 'build', 'web');
app.use(express.static(webPath, {
  // Set custom MIME types for font files
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('.otf')) {
      res.setHeader('Content-Type', 'font/otf');
    } else if (filePath.endsWith('.woff')) {
      res.setHeader('Content-Type', 'font/woff');
    } else if (filePath.endsWith('.woff2')) {
      res.setHeader('Content-Type', 'font/woff2');
    }
  }
}));

// Fallback to index.html for all other routes (SPA routing)
app.use((req, res) => {
  res.sendFile(path.join(webPath, 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('🎉 Frontend Server Started!');
  console.log('================================');
  console.log(`📱 Local:    http://localhost:${PORT}`);
  console.log(`🌐 Network:  http://10.248.24.199:${PORT}`);
  console.log('================================');
  console.log('');
  console.log('✅ Backend API: http://localhost:8081');
  console.log('✅ Frontend:    http://localhost:8080');
  console.log('');
  console.log('📂 Serving from: flutter_app/build/web');
  console.log('');
  console.log('Press Ctrl+C to stop');
  console.log('');
});

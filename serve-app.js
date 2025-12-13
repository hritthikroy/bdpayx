const express = require('express');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 8080;

// Enable CORS
app.use(cors());

// Serve static files from Flutter web directory
const webPath = path.join(__dirname, 'flutter_app', 'build', 'web');
app.use(express.static(webPath));

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
  console.log('✅ Backend API: http://localhost:3000');
  console.log('✅ Frontend:    http://localhost:8080');
  console.log('');
  console.log('📂 Serving from: flutter_app/build/web');
  console.log('');
  console.log('Press Ctrl+C to stop');
  console.log('');
});

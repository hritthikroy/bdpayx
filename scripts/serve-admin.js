const express = require('express');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 8080;

// Enable CORS
app.use(cors());

// Serve static files from admin dashboard directory
const adminPath = path.join(__dirname, '..', 'admin-dashboard');
app.use(express.static(adminPath));

// Fallback to index.html for all other routes (SPA routing)
app.use((req, res) => {
  res.sendFile(path.join(adminPath, 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('🎉 Admin Dashboard Server Started!');
  console.log('================================');
  console.log(`📱 Local:    http://localhost:${PORT}`);
  console.log('================================');
  console.log('');
  console.log('✅ Backend API: http://localhost:3000');
  console.log('✅ Admin:       http://localhost:8080');
  console.log('');
  console.log('📂 Serving from: admin-dashboard');
  console.log('');
  console.log('Press Ctrl+C to stop');
  console.log('');
});
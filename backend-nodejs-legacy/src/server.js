require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const rateService = require('./services/rateService');

const authRoutes = require('./routes/auth');
const exchangeRoutes = require('./routes/exchange');
const transactionRoutes = require('./routes/transactions');
const adminRoutes = require('./routes/admin');
const adminEnhancedRoutes = require('./routes/admin-enhanced');
const chatRoutes = require('./routes/chat');
const walletRoutes = require('./routes/wallet');
const googleAuthRoutes = require('./routes/google-auth');
const supportRoutes = require('./routes/support');
const smsWebhookRoutes = require('./routes/smsWebhook');
const RealtimeMonitor = require('./services/realtime-monitor');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.NODE_ENV === 'production' ? process.env.FRONTEND_URL : '*',
    methods: ['GET', 'POST'],
    credentials: true
  },
  transports: ['websocket', 'polling']
});

// Enhanced middleware
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? process.env.FRONTEND_URL : '*',
  credentials: true
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use('/uploads', express.static('uploads'));

// Request logging middleware (only in development)
if (process.env.NODE_ENV !== 'production') {
  app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
  });
}

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/auth', googleAuthRoutes);
app.use('/api/exchange', exchangeRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/admin/v2', adminEnhancedRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/support', supportRoutes);
app.use('/api/sms-webhook', smsWebhookRoutes);

// Make io available to routes
app.set('io', io);

// Start dynamic rate fluctuation
rateService.startRateFluctuation();

// Initialize real-time monitoring
const realtimeMonitor = new RealtimeMonitor(io);
realtimeMonitor.initialize();

// Socket.io for live chat and rate updates
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join_support', (userId) => {
    socket.join(`support_${userId}`);
  });

  socket.on('send_message', (data) => {
    io.to(`support_${data.userId}`).emit('receive_message', data);
    // Notify admins of new message
    io.to('admin_room').emit('new_support_message', data);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Make io and monitor accessible to routes
app.set('io', io);
app.set('monitor', realtimeMonitor);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler for undefined routes
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    env: process.env.NODE_ENV || 'development'
  });
});

// Handle server errors
server.on('error', (error) => {
  if (error.syscall !== 'listen') {
    throw error;
  }

  const bind = typeof PORT === 'string' ? 'Pipe ' + PORT : 'Port ' + PORT;

  switch (error.code) {
    case 'EACCES':
      console.error(bind + ' requires elevated privileges');
      process.exit(1);
      break;
    case 'EADDRINUSE':
      console.error(bind + ' is already in use');
      process.exit(1);
      break;
    default:
      throw error;
  }
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(``);
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Frontend URL: ${process.env.FRONTEND_URL || 'http://localhost:8080'}`);
  console.log(`📊 API endpoints available at: http://localhost:${PORT}/api/health`);
  console.log(``);
});

module.exports = { app, server };

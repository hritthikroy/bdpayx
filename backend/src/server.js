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
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));

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

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

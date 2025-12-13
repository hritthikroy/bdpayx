// Real-time monitoring service for admin
const { supabase } = require('../config/supabase');

class RealtimeMonitor {
  constructor(io) {
    this.io = io;
    this.activeUsers = new Map();
    this.systemStats = {
      totalUsers: 0,
      activeUsers: 0,
      pendingTransactions: 0,
      todayVolume: 0
    };
  }

  // Initialize real-time monitoring
  async initialize() {
    console.log('🔴 Initializing real-time monitoring...');
    
    // Track user connections
    this.io.on('connection', (socket) => {
      console.log(`User connected: ${socket.id}`);
      
      // User authentication
      socket.on('authenticate', async (data) => {
        const { userId, role } = data;
        socket.userId = userId;
        socket.role = role;
        
        // Join user-specific room
        socket.join(`user_${userId}`);
        
        // If admin, join admin room
        if (role === 'admin' || role === 'super_admin') {
          socket.join('admin_room');
          this.sendAdminStats(socket);
        }
        
        // Track active user
        this.activeUsers.set(userId, {
          socketId: socket.id,
          connectedAt: new Date(),
          role
        });
        
        // Broadcast to admins
        this.broadcastToAdmins('user_online', { userId, timestamp: new Date() });
      });

      // Handle disconnection
      socket.on('disconnect', () => {
        if (socket.userId) {
          this.activeUsers.delete(socket.userId);
          this.broadcastToAdmins('user_offline', { 
            userId: socket.userId, 
            timestamp: new Date() 
          });
        }
        console.log(`User disconnected: ${socket.id}`);
      });

      // Admin requests real-time data
      socket.on('admin_request_stats', () => {
        if (socket.role === 'admin' || socket.role === 'super_admin') {
          this.sendAdminStats(socket);
        }
      });
    });

    // Start monitoring loops
    this.startTransactionMonitoring();
    this.startUserActivityMonitoring();
    this.startSystemStatsUpdate();
  }

  // Monitor transactions in real-time
  startTransactionMonitoring() {
    // Subscribe to transaction changes
    supabase
      .channel('transactions')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'transactions' },
        async (payload) => {
          console.log('Transaction change:', payload);
          
          const { eventType, new: newRecord, old: oldRecord } = payload;
          
          // Notify admin room
          this.broadcastToAdmins('transaction_event', {
            type: eventType,
            transaction: newRecord || oldRecord,
            timestamp: new Date()
          });

          // Notify specific user
          if (newRecord?.user_id) {
            this.io.to(`user_${newRecord.user_id}`).emit('transaction_updated', {
              transaction: newRecord
            });
          }

          // Update stats
          await this.updateSystemStats();
        }
      )
      .subscribe();
  }

  // Monitor user activity
  startUserActivityMonitoring() {
    // Subscribe to user changes
    supabase
      .channel('users')
      .on('postgres_changes',
        { event: '*', schema: 'public', table: 'users' },
        async (payload) => {
          console.log('User change:', payload);
          
          const { eventType, new: newRecord } = payload;
          
          // Notify admins
          this.broadcastToAdmins('user_event', {
            type: eventType,
            user: newRecord,
            timestamp: new Date()
          });

          // Update stats
          await this.updateSystemStats();
        }
      )
      .subscribe();
  }

  // Update system stats periodically
  startSystemStatsUpdate() {
    setInterval(async () => {
      await this.updateSystemStats();
      this.broadcastToAdmins('system_stats', this.systemStats);
    }, 30000); // Every 30 seconds
  }

  // Update system statistics
  async updateSystemStats() {
    try {
      // Total users
      const { count: totalUsers } = await supabase
        .from('users')
        .select('*', { count: 'exact', head: true });

      // Pending transactions
      const { count: pendingTransactions } = await supabase
        .from('transactions')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'pending');

      // Today's volume
      const today = new Date().toISOString().split('T')[0];
      const { data: todayTransactions } = await supabase
        .from('transactions')
        .select('bdt_amount')
        .gte('created_at', today)
        .eq('status', 'completed');

      const todayVolume = todayTransactions?.reduce(
        (sum, t) => sum + parseFloat(t.bdt_amount || 0), 
        0
      ) || 0;

      this.systemStats = {
        totalUsers: totalUsers || 0,
        activeUsers: this.activeUsers.size,
        pendingTransactions: pendingTransactions || 0,
        todayVolume: todayVolume.toFixed(2),
        lastUpdated: new Date()
      };
    } catch (error) {
      console.error('Error updating system stats:', error);
    }
  }

  // Send stats to admin
  async sendAdminStats(socket) {
    await this.updateSystemStats();
    socket.emit('admin_stats', {
      ...this.systemStats,
      activeUsersList: Array.from(this.activeUsers.entries()).map(([userId, data]) => ({
        userId,
        ...data
      }))
    });
  }

  // Broadcast to all admins
  broadcastToAdmins(event, data) {
    this.io.to('admin_room').emit(event, data);
  }

  // Send notification to specific user
  notifyUser(userId, event, data) {
    this.io.to(`user_${userId}`).emit(event, data);
  }

  // Broadcast to all users
  broadcastToAll(event, data) {
    this.io.emit(event, data);
  }

  // Get active users count
  getActiveUsersCount() {
    return this.activeUsers.size;
  }

  // Get active users list
  getActiveUsers() {
    return Array.from(this.activeUsers.entries());
  }
}

module.exports = RealtimeMonitor;

const express = require('express');
const router = express.Router();
const { adminAuth, superAdminAuth } = require('../middleware/adminAuth');
const { supabase } = require('../config/supabase');

// ============================================
// DASHBOARD & ANALYTICS
// ============================================

// Get dashboard overview
router.get('/dashboard', adminAuth, async (req, res) => {
  try {
    // Get counts
    const { count: totalUsers } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true });

    const { count: activeUsers } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true })
      .gte('last_login', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString());

    const { count: pendingTransactions } = await supabase
      .from('transactions')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'pending');

    const { count: pendingKYC } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true })
      .eq('kyc_status', 'pending');

    // Get total volume
    const { data: volumeData } = await supabase
      .from('transactions')
      .select('bdt_amount, inr_amount, status')
      .eq('status', 'completed');

    const totalVolume = volumeData?.reduce((sum, t) => sum + parseFloat(t.bdt_amount || 0), 0) || 0;
    const totalRevenue = volumeData?.reduce((sum, t) => sum + parseFloat(t.inr_amount || 0), 0) || 0;

    // Recent transactions
    const { data: recentTransactions } = await supabase
      .from('transactions')
      .select(`
        *,
        users:user_id (id, phone, full_name, email)
      `)
      .order('created_at', { ascending: false })
      .limit(10);

    // Today's stats
    const today = new Date().toISOString().split('T')[0];
    const { count: todayTransactions } = await supabase
      .from('transactions')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', today);

    const { count: todayUsers } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', today);

    res.json({
      overview: {
        totalUsers,
        activeUsers,
        pendingTransactions,
        pendingKYC,
        totalVolume: totalVolume.toFixed(2),
        totalRevenue: totalRevenue.toFixed(2),
        todayTransactions,
        todayUsers
      },
      recentTransactions
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: 'Failed to load dashboard' });
  }
});

// Get analytics data
router.get('/analytics', adminAuth, async (req, res) => {
  try {
    const { period = '7d' } = req.query;
    
    let startDate = new Date();
    if (period === '7d') startDate.setDate(startDate.getDate() - 7);
    else if (period === '30d') startDate.setDate(startDate.getDate() - 30);
    else if (period === '90d') startDate.setDate(startDate.getDate() - 90);

    // Transaction trends
    const { data: transactions } = await supabase
      .from('transactions')
      .select('created_at, bdt_amount, status')
      .gte('created_at', startDate.toISOString());

    // User growth
    const { data: users } = await supabase
      .from('users')
      .select('created_at')
      .gte('created_at', startDate.toISOString());

    // Group by date
    const transactionsByDate = {};
    const usersByDate = {};

    transactions?.forEach(t => {
      const date = t.created_at.split('T')[0];
      if (!transactionsByDate[date]) {
        transactionsByDate[date] = { count: 0, volume: 0 };
      }
      transactionsByDate[date].count++;
      transactionsByDate[date].volume += parseFloat(t.bdt_amount || 0);
    });

    users?.forEach(u => {
      const date = u.created_at.split('T')[0];
      usersByDate[date] = (usersByDate[date] || 0) + 1;
    });

    res.json({
      transactionTrends: transactionsByDate,
      userGrowth: usersByDate,
      period
    });
  } catch (error) {
    console.error('Analytics error:', error);
    res.status(500).json({ error: 'Failed to load analytics' });
  }
});

// ============================================
// USER MANAGEMENT
// ============================================

// Get all users with filters
router.get('/users', adminAuth, async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      search = '', 
      status = 'all',
      kyc_status = 'all',
      sort = 'created_at',
      order = 'desc'
    } = req.query;

    let query = supabase
      .from('users')
      .select('*', { count: 'exact' });

    // Search
    if (search) {
      query = query.or(`phone.ilike.%${search}%,email.ilike.%${search}%,full_name.ilike.%${search}%`);
    }

    // Filters
    if (status !== 'all') {
      query = query.eq('status', status);
    }
    if (kyc_status !== 'all') {
      query = query.eq('kyc_status', kyc_status);
    }

    // Sorting
    query = query.order(sort, { ascending: order === 'asc' });

    // Pagination
    const from = (page - 1) * limit;
    const to = from + limit - 1;
    query = query.range(from, to);

    const { data: users, error, count } = await query;

    if (error) throw error;

    res.json({
      users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Get single user details
router.get('/users/:userId', adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;

    // Get user
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (userError) throw userError;

    // Get user transactions
    const { data: transactions } = await supabase
      .from('transactions')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(50);

    // Get user stats
    const { data: stats } = await supabase
      .from('transactions')
      .select('bdt_amount, inr_amount, status')
      .eq('user_id', userId);

    const totalTransactions = stats?.length || 0;
    const completedTransactions = stats?.filter(t => t.status === 'completed').length || 0;
    const totalVolume = stats?.reduce((sum, t) => sum + parseFloat(t.bdt_amount || 0), 0) || 0;

    res.json({
      user,
      transactions,
      stats: {
        totalTransactions,
        completedTransactions,
        totalVolume: totalVolume.toFixed(2)
      }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

// Update user
router.put('/users/:userId', adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const updates = req.body;

    // Don't allow updating sensitive fields
    delete updates.id;
    delete updates.password;
    delete updates.created_at;

    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', userId)
      .select()
      .single();

    if (error) throw error;

    // Log admin action
    await supabase.from('admin_logs').insert({
      admin_id: req.userId,
      action: 'update_user',
      target_id: userId,
      details: updates
    });

    res.json({ user: data, message: 'User updated successfully' });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Failed to update user' });
  }
});

// Block/Unblock user
router.post('/users/:userId/toggle-status', adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;

    const { data: user } = await supabase
      .from('users')
      .select('status')
      .eq('id', userId)
      .single();

    const newStatus = user.status === 'active' ? 'blocked' : 'active';

    const { data, error } = await supabase
      .from('users')
      .update({ status: newStatus })
      .eq('id', userId)
      .select()
      .single();

    if (error) throw error;

    // Log action
    await supabase.from('admin_logs').insert({
      admin_id: req.userId,
      action: newStatus === 'blocked' ? 'block_user' : 'unblock_user',
      target_id: userId
    });

    res.json({ user: data, message: `User ${newStatus}` });
  } catch (error) {
    console.error('Toggle user status error:', error);
    res.status(500).json({ error: 'Failed to update user status' });
  }
});

// ============================================
// TRANSACTION MANAGEMENT
// ============================================

// Get all transactions
router.get('/transactions', adminAuth, async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      status = 'all',
      user_id = null,
      from_date = null,
      to_date = null
    } = req.query;

    let query = supabase
      .from('transactions')
      .select(`
        *,
        users:user_id (id, phone, full_name, email)
      `, { count: 'exact' });

    // Filters
    if (status !== 'all') {
      query = query.eq('status', status);
    }
    if (user_id) {
      query = query.eq('user_id', user_id);
    }
    if (from_date) {
      query = query.gte('created_at', from_date);
    }
    if (to_date) {
      query = query.lte('created_at', to_date);
    }

    // Pagination
    const from = (page - 1) * limit;
    const to = from + limit - 1;
    query = query.order('created_at', { ascending: false }).range(from, to);

    const { data: transactions, error, count } = await query;

    if (error) throw error;

    res.json({
      transactions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

// Update transaction status
router.put('/transactions/:transactionId/status', adminAuth, async (req, res) => {
  try {
    const { transactionId } = req.params;
    const { status, admin_note } = req.body;

    const validStatuses = ['pending', 'processing', 'completed', 'rejected', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const { data, error } = await supabase
      .from('transactions')
      .update({ 
        status,
        admin_note,
        updated_at: new Date().toISOString()
      })
      .eq('id', transactionId)
      .select()
      .single();

    if (error) throw error;

    // If completed, update user balance
    if (status === 'completed') {
      const { data: transaction } = await supabase
        .from('transactions')
        .select('user_id, inr_amount')
        .eq('id', transactionId)
        .single();

      if (transaction) {
        await supabase.rpc('update_user_balance', {
          p_user_id: transaction.user_id,
          p_amount: parseFloat(transaction.inr_amount)
        });
      }
    }

    // Log action
    await supabase.from('admin_logs').insert({
      admin_id: req.userId,
      action: 'update_transaction_status',
      target_id: transactionId,
      details: { status, admin_note }
    });

    // Emit socket event for real-time update
    const io = req.app.get('io');
    io.emit('transaction_updated', { transactionId, status });

    res.json({ transaction: data, message: 'Transaction updated' });
  } catch (error) {
    console.error('Update transaction error:', error);
    res.status(500).json({ error: 'Failed to update transaction' });
  }
});

// ============================================
// KYC MANAGEMENT
// ============================================

// Get pending KYC requests
router.get('/kyc/pending', adminAuth, async (req, res) => {
  try {
    const { data: users, error } = await supabase
      .from('users')
      .select('*')
      .eq('kyc_status', 'pending')
      .order('created_at', { ascending: false });

    if (error) throw error;

    res.json({ users });
  } catch (error) {
    console.error('Get pending KYC error:', error);
    res.status(500).json({ error: 'Failed to fetch KYC requests' });
  }
});

// Approve/Reject KYC
router.post('/kyc/:userId/review', adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const { status, rejection_reason } = req.body;

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const updates = {
      kyc_status: status,
      kyc_reviewed_at: new Date().toISOString(),
      kyc_reviewed_by: req.userId
    };

    if (status === 'rejected' && rejection_reason) {
      updates.kyc_rejection_reason = rejection_reason;
    }

    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', userId)
      .select()
      .single();

    if (error) throw error;

    // Log action
    await supabase.from('admin_logs').insert({
      admin_id: req.userId,
      action: `kyc_${status}`,
      target_id: userId,
      details: { rejection_reason }
    });

    // Emit socket event
    const io = req.app.get('io');
    io.to(`user_${userId}`).emit('kyc_updated', { status });

    res.json({ user: data, message: `KYC ${status}` });
  } catch (error) {
    console.error('Review KYC error:', error);
    res.status(500).json({ error: 'Failed to review KYC' });
  }
});

// ============================================
// EXCHANGE RATE MANAGEMENT
// ============================================

// Update exchange rate
router.post('/exchange-rate/update', adminAuth, async (req, res) => {
  try {
    const { base_rate } = req.body;

    if (!base_rate || base_rate <= 0) {
      return res.status(400).json({ error: 'Invalid rate' });
    }

    const { data, error } = await supabase
      .from('exchange_rates')
      .update({
        base_rate,
        updated_at: new Date().toISOString(),
        updated_by: req.userId
      })
      .eq('from_currency', 'BDT')
      .eq('to_currency', 'INR')
      .select()
      .single();

    if (error) throw error;

    // Log action
    await supabase.from('admin_logs').insert({
      admin_id: req.userId,
      action: 'update_exchange_rate',
      details: { base_rate }
    });

    // Emit socket event
    const io = req.app.get('io');
    io.emit('rate_updated', { base_rate });

    res.json({ rate: data, message: 'Rate updated successfully' });
  } catch (error) {
    console.error('Update rate error:', error);
    res.status(500).json({ error: 'Failed to update rate' });
  }
});

// Get rate history
router.get('/exchange-rate/history', adminAuth, async (req, res) => {
  try {
    const { limit = 50 } = req.query;

    const { data, error } = await supabase
      .from('rate_history')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;

    res.json({ history: data });
  } catch (error) {
    console.error('Get rate history error:', error);
    res.status(500).json({ error: 'Failed to fetch rate history' });
  }
});

// ============================================
// NOTIFICATIONS & ANNOUNCEMENTS
// ============================================

// Send notification to user
router.post('/notifications/send', adminAuth, async (req, res) => {
  try {
    const { user_id, title, message, type = 'info' } = req.body;

    const { data, error } = await supabase
      .from('notifications')
      .insert({
        user_id,
        title,
        message,
        type,
        created_by: req.userId
      })
      .select()
      .single();

    if (error) throw error;

    // Emit socket event
    const io = req.app.get('io');
    io.to(`user_${user_id}`).emit('notification', data);

    res.json({ notification: data, message: 'Notification sent' });
  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({ error: 'Failed to send notification' });
  }
});

// Broadcast announcement
router.post('/announcements/broadcast', adminAuth, async (req, res) => {
  try {
    const { title, message, type = 'info' } = req.body;

    const { data, error } = await supabase
      .from('announcements')
      .insert({
        title,
        message,
        type,
        created_by: req.userId
      })
      .select()
      .single();

    if (error) throw error;

    // Emit socket event to all users
    const io = req.app.get('io');
    io.emit('announcement', data);

    res.json({ announcement: data, message: 'Announcement broadcasted' });
  } catch (error) {
    console.error('Broadcast announcement error:', error);
    res.status(500).json({ error: 'Failed to broadcast announcement' });
  }
});

// ============================================
// ADMIN LOGS
// ============================================

// Get admin activity logs
router.get('/logs', adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 50, admin_id = null } = req.query;

    let query = supabase
      .from('admin_logs')
      .select(`
        *,
        admin:admin_id (id, full_name, email)
      `, { count: 'exact' });

    if (admin_id) {
      query = query.eq('admin_id', admin_id);
    }

    const from = (page - 1) * limit;
    const to = from + limit - 1;
    query = query.order('created_at', { ascending: false }).range(from, to);

    const { data: logs, error, count } = await query;

    if (error) throw error;

    res.json({
      logs,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        pages: Math.ceil(count / limit)
      }
    });
  } catch (error) {
    console.error('Get logs error:', error);
    res.status(500).json({ error: 'Failed to fetch logs' });
  }
});

// ============================================
// SYSTEM SETTINGS
// ============================================

// Get system settings
router.get('/settings', adminAuth, async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('system_settings')
      .select('*');

    if (error) throw error;

    const settings = {};
    data?.forEach(s => {
      settings[s.key] = s.value;
    });

    res.json({ settings });
  } catch (error) {
    console.error('Get settings error:', error);
    res.status(500).json({ error: 'Failed to fetch settings' });
  }
});

// Update system setting
router.put('/settings/:key', superAdminAuth, async (req, res) => {
  try {
    const { key } = req.params;
    const { value } = req.body;

    const { data, error } = await supabase
      .from('system_settings')
      .upsert({
        key,
        value,
        updated_by: req.userId,
        updated_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;

    // Log action
    await supabase.from('admin_logs').insert({
      admin_id: req.userId,
      action: 'update_setting',
      details: { key, value }
    });

    res.json({ setting: data, message: 'Setting updated' });
  } catch (error) {
    console.error('Update setting error:', error);
    res.status(500).json({ error: 'Failed to update setting' });
  }
});

// ============================================
// REPORTS
// ============================================

// Generate report
router.post('/reports/generate', adminAuth, async (req, res) => {
  try {
    const { type, from_date, to_date } = req.body;

    let data;
    
    if (type === 'transactions') {
      const { data: transactions } = await supabase
        .from('transactions')
        .select('*')
        .gte('created_at', from_date)
        .lte('created_at', to_date);
      data = transactions;
    } else if (type === 'users') {
      const { data: users } = await supabase
        .from('users')
        .select('*')
        .gte('created_at', from_date)
        .lte('created_at', to_date);
      data = users;
    }

    res.json({ report: data, type, from_date, to_date });
  } catch (error) {
    console.error('Generate report error:', error);
    res.status(500).json({ error: 'Failed to generate report' });
  }
});

module.exports = router;

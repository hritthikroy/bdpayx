const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { adminAuth } = require('../middleware/adminAuth');
const { authMiddleware } = require('../middleware/auth');

// Get all support tickets (Admin)
router.get('/tickets', adminAuth, async (req, res) => {
    try {
        const { status, priority, category, search } = req.query;
        
        let query = supabase
            .from('support_tickets')
            .select(`
                *,
                users:user_id (id, full_name, phone, email),
                admin_users:assigned_to (id, full_name, email),
                support_messages (count)
            `)
            .order('created_at', { ascending: false });

        if (status && status !== 'all') {
            query = query.eq('status', status);
        }
        if (priority && priority !== 'all') {
            query = query.eq('priority', priority);
        }
        if (category && category !== 'all') {
            query = query.eq('category', category);
        }
        if (search) {
            query = query.or(`subject.ilike.%${search}%`);
        }

        const { data, error } = await query;

        if (error) throw error;

        res.json({ tickets: data });
    } catch (error) {
        console.error('Get tickets error:', error);
        res.status(500).json({ error: 'Failed to fetch tickets' });
    }
});

// Get single ticket with messages (Admin)
router.get('/tickets/:id', adminAuth, async (req, res) => {
    try {
        const { id } = req.params;

        const { data: ticket, error: ticketError } = await supabase
            .from('support_tickets')
            .select(`
                *,
                users:user_id (id, full_name, phone, email),
                admin_users:assigned_to (id, full_name, email)
            `)
            .eq('id', id)
            .single();

        if (ticketError) throw ticketError;

        const { data: messages, error: messagesError } = await supabase
            .from('support_messages')
            .select('*')
            .eq('ticket_id', id)
            .order('created_at', { ascending: true });

        if (messagesError) throw messagesError;

        res.json({ ticket, messages });
    } catch (error) {
        console.error('Get ticket error:', error);
        res.status(500).json({ error: 'Failed to fetch ticket' });
    }
});

// Reply to ticket (Admin)
router.post('/tickets/:id/reply', adminAuth, async (req, res) => {
    try {
        const { id } = req.params;
        const { message } = req.body;
        const adminId = req.userId;

        // Insert message
        const { data: newMessage, error: messageError } = await supabase
            .from('support_messages')
            .insert({
                ticket_id: id,
                sender_id: adminId,
                sender_type: 'admin',
                message
            })
            .select()
            .single();

        if (messageError) throw messageError;

        // Update ticket status and timestamp
        const { error: updateError } = await supabase
            .from('support_tickets')
            .update({ 
                status: 'replied',
                updated_at: new Date().toISOString()
            })
            .eq('id', id);

        if (updateError) throw updateError;

        // Emit real-time event
        req.app.get('io').emit('support_reply', {
            ticketId: id,
            message: newMessage
        });

        res.json({ message: newMessage });
    } catch (error) {
        console.error('Reply to ticket error:', error);
        res.status(500).json({ error: 'Failed to send reply' });
    }
});

// Update ticket status (Admin)
router.put('/tickets/:id/status', adminAuth, async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const updateData = { 
            status,
            updated_at: new Date().toISOString()
        };

        if (status === 'closed') {
            updateData.closed_at = new Date().toISOString();
        }

        const { data, error } = await supabase
            .from('support_tickets')
            .update(updateData)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;

        res.json({ ticket: data });
    } catch (error) {
        console.error('Update ticket status error:', error);
        res.status(500).json({ error: 'Failed to update ticket status' });
    }
});

// Assign ticket to admin (Admin)
router.put('/tickets/:id/assign', adminAuth, async (req, res) => {
    try {
        const { id } = req.params;
        const { admin_id } = req.body;

        const { data, error } = await supabase
            .from('support_tickets')
            .update({ 
                assigned_to: admin_id,
                updated_at: new Date().toISOString()
            })
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;

        res.json({ ticket: data });
    } catch (error) {
        console.error('Assign ticket error:', error);
        res.status(500).json({ error: 'Failed to assign ticket' });
    }
});

// Update ticket priority (Admin)
router.put('/tickets/:id/priority', adminAuth, async (req, res) => {
    try {
        const { id } = req.params;
        const { priority } = req.body;

        const { data, error } = await supabase
            .from('support_tickets')
            .update({ 
                priority,
                updated_at: new Date().toISOString()
            })
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;

        res.json({ ticket: data });
    } catch (error) {
        console.error('Update ticket priority error:', error);
        res.status(500).json({ error: 'Failed to update ticket priority' });
    }
});

// Get support statistics (Admin)
router.get('/stats', adminAuth, async (req, res) => {
    try {
        const { data: tickets, error } = await supabase
            .from('support_tickets')
            .select('status, priority, category');

        if (error) throw error;

        const stats = {
            total: tickets.length,
            open: tickets.filter(t => t.status === 'open').length,
            replied: tickets.filter(t => t.status === 'replied').length,
            closed: tickets.filter(t => t.status === 'closed').length,
            high_priority: tickets.filter(t => t.priority === 'high').length,
            by_category: {}
        };

        tickets.forEach(t => {
            stats.by_category[t.category] = (stats.by_category[t.category] || 0) + 1;
        });

        res.json(stats);
    } catch (error) {
        console.error('Get support stats error:', error);
        res.status(500).json({ error: 'Failed to fetch support statistics' });
    }
});

// User endpoints
// Create support ticket (User)
router.post('/tickets/create', authMiddleware, async (req, res) => {
    try {
        const { subject, category, message } = req.body;
        const userId = req.userId;

        // Create ticket
        const { data: ticket, error: ticketError } = await supabase
            .from('support_tickets')
            .insert({
                user_id: userId,
                subject,
                category: category || 'general',
                status: 'open',
                priority: 'normal'
            })
            .select()
            .single();

        if (ticketError) throw ticketError;

        // Add initial message
        const { error: messageError } = await supabase
            .from('support_messages')
            .insert({
                ticket_id: ticket.id,
                sender_id: userId,
                sender_type: 'user',
                message
            });

        if (messageError) throw messageError;

        // Emit real-time event
        req.app.get('io').emit('new_support_ticket', {
            ticketId: ticket.id,
            userId
        });

        res.json({ ticket });
    } catch (error) {
        console.error('Create ticket error:', error);
        res.status(500).json({ error: 'Failed to create ticket' });
    }
});

// Get user's tickets
router.get('/my-tickets', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId;

        const { data, error } = await supabase
            .from('support_tickets')
            .select(`
                *,
                support_messages (count)
            `)
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) throw error;

        res.json({ tickets: data });
    } catch (error) {
        console.error('Get user tickets error:', error);
        res.status(500).json({ error: 'Failed to fetch tickets' });
    }
});

// Add message to ticket (User)
router.post('/tickets/:id/message', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const { message } = req.body;
        const userId = req.user.userId;

        // Verify ticket belongs to user
        const { data: ticket, error: ticketError } = await supabase
            .from('support_tickets')
            .select('user_id')
            .eq('id', id)
            .single();

        if (ticketError || ticket.user_id !== userId) {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        // Insert message
        const { data: newMessage, error: messageError } = await supabase
            .from('support_messages')
            .insert({
                ticket_id: id,
                sender_id: userId,
                sender_type: 'user',
                message
            })
            .select()
            .single();

        if (messageError) throw messageError;

        // Update ticket status
        await supabase
            .from('support_tickets')
            .update({ 
                status: 'open',
                updated_at: new Date().toISOString()
            })
            .eq('id', id);

        res.json({ message: newMessage });
    } catch (error) {
        console.error('Add message error:', error);
        res.status(500).json({ error: 'Failed to add message' });
    }
});

module.exports = router;

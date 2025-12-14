// Admin Dashboard JavaScript
const API_BASE = 'http://localhost:8081/api';
let socket;
let authToken = localStorage.getItem('admin_token');
let currentTransactionId = null;
let isLoadingDashboard = false;
let dashboardLoadTimeout = null;

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    if (!authToken) {
        window.location.href = 'login.html';
        return;
    }

    initializeSocket();
    loadDashboard();
    setupNavigation();
    setupEventListeners();
});

// Socket.IO Connection
function initializeSocket() {
    socket = io('http://localhost:8081');
    
    socket.on('connect', () => {
        console.log('Connected to server');
        // Authenticate as admin
        socket.emit('authenticate', {
            userId: getUserIdFromToken(),
            role: 'admin'
        });
    });

    // Real-time events
    socket.on('admin_stats', (data) => {
        updateDashboardStats(data);
    });

    socket.on('transaction_event', (data) => {
        console.log('Transaction event:', data);
        showNotification(`New ${data.type} transaction`, 'info');
        // Debounce dashboard reload
        clearTimeout(dashboardLoadTimeout);
        dashboardLoadTimeout = setTimeout(() => loadDashboard(), 1000);
    });

    socket.on('user_event', (data) => {
        console.log('User event:', data);
        if (data.type === 'INSERT') {
            showNotification('New user registered', 'success');
        }
        // Debounce dashboard reload
        clearTimeout(dashboardLoadTimeout);
        dashboardLoadTimeout = setTimeout(() => loadDashboard(), 1000);
    });

    socket.on('user_online', (data) => {
        console.log('User online:', data.userId);
    });

    socket.on('user_offline', (data) => {
        console.log('User offline:', data.userId);
    });

    socket.on('new_support_message', (data) => {
        showNotification('New support message', 'info');
    });

    socket.on('new_support_ticket', (data) => {
        showNotification('New support ticket created', 'info');
        loadSupportStats();
        if (document.getElementById('support-page').classList.contains('active')) {
            loadSupportTickets();
        }
    });

    socket.on('support_reply', (data) => {
        if (currentTicketId === data.ticketId) {
            viewTicket(data.ticketId);
        }
    });

    // Request initial stats
    socket.emit('admin_request_stats');
}

// Navigation
function setupNavigation() {
    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const page = item.dataset.page;
            navigateToPage(page);
        });
    });
}

function navigateToPage(page) {
    // Update active nav item
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.remove('active');
    });
    document.querySelector(`[data-page="${page}"]`).classList.add('active');

    // Show page
    document.querySelectorAll('.page').forEach(p => {
        p.classList.remove('active');
    });
    document.getElementById(`${page}-page`).classList.add('active');

    // Update title
    const titles = {
        dashboard: 'Dashboard',
        users: 'User Management',
        transactions: 'Transactions',
        kyc: 'KYC Requests',
        exchange: 'Exchange Rate',
        support: 'Support Tickets',
        notifications: 'Notifications',
        analytics: 'Analytics',
        settings: 'Settings',
        logs: 'Activity Logs'
    };
    document.getElementById('page-title').textContent = titles[page];

    // Load page data
    switch(page) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'users':
            loadUsers();
            break;
        case 'transactions':
            loadTransactions();
            break;
        case 'kyc':
            loadKYCRequests();
            break;
        case 'exchange':
            loadExchangeRate();
            break;
        case 'support':
            loadSupportTickets();
            loadSupportStats();
            break;
        case 'analytics':
            loadAnalytics();
            break;
        case 'logs':
            loadLogs();
            break;
    }
}

// Dashboard
async function loadDashboard() {
    // Prevent double loading
    if (isLoadingDashboard) {
        console.log('Dashboard already loading, skipping...');
        return;
    }
    
    isLoadingDashboard = true;
    
    try {
        const response = await fetch(`${API_BASE}/admin/v2/dashboard`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        
        const data = await response.json();
        console.log('Dashboard data received:', data);
        
        // Check for API error response
        if (data && data.error) {
            console.error('Dashboard API error:', data.error);
            if (data.error === 'Invalid token' || data.error === 'Unauthorized') {
                showNotification('Session expired. Please login again.', 'error');
                setTimeout(() => {
                    localStorage.removeItem('admin_token');
                    window.location.href = 'login.html';
                }, 2000);
            } else {
                showNotification('Failed to load dashboard: ' + data.error, 'error');
            }
            return;
        }
        
        if (!response.ok) {
            console.error('Dashboard API error:', response.status, response.statusText);
            showNotification('Failed to load dashboard', 'error');
            return;
        }

        // Check if data has the expected structure - DEFENSIVE CHECK
        if (!data || typeof data !== 'object' || !data.overview || typeof data.overview !== 'object') {
            console.error('Invalid dashboard data structure:', data);
            showNotification('Failed to load dashboard data', 'error');
            return;
        }

        // Update stats - with safe access
        const overview = data.overview || {};
        document.getElementById('total-users').textContent = overview.totalUsers || 0;
        document.getElementById('active-users').textContent = overview.activeUsers || 0;
        document.getElementById('pending-transactions').textContent = overview.pendingTransactions || 0;
        document.getElementById('today-volume').textContent = parseFloat(overview.totalVolume || 0).toLocaleString();
        document.getElementById('kyc-badge').textContent = overview.pendingKYC || 0;

        // Load recent transactions
        if (data.recentTransactions && Array.isArray(data.recentTransactions)) {
            loadRecentTransactions(data.recentTransactions);
        }
    } catch (error) {
        console.error('Load dashboard error:', error);
        showNotification('Error loading dashboard', 'error');
    } finally {
        // Reset loading flag after a short delay
        setTimeout(() => {
            isLoadingDashboard = false;
        }, 500);
    }
}

function updateDashboardStats(stats) {
    document.getElementById('total-users').textContent = stats.totalUsers;
    document.getElementById('active-users').textContent = stats.activeUsers;
    document.getElementById('pending-transactions').textContent = stats.pendingTransactions;
    document.getElementById('today-volume').textContent = parseFloat(stats.todayVolume).toLocaleString();
}

function loadRecentTransactions(transactions) {
    const tbody = document.querySelector('#recent-transactions tbody');
    tbody.innerHTML = '';

    transactions.forEach(t => {
        const row = `
            <tr>
                <td>#${t.id}</td>
                <td>${t.users?.full_name || 'N/A'}</td>
                <td>${parseFloat(t.bdt_amount).toLocaleString()} BDT</td>
                <td>${parseFloat(t.inr_amount).toLocaleString()} INR</td>
                <td><span class="status-badge status-${t.status}">${t.status}</span></td>
                <td>${new Date(t.created_at).toLocaleString()}</td>
                <td>
                    <button class="btn btn-primary" onclick="viewTransaction(${t.id})">View</button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

// Users
async function loadUsers() {
    try {
        const search = document.getElementById('user-search')?.value || '';
        const status = document.getElementById('user-status-filter')?.value || 'all';
        const kyc = document.getElementById('kyc-status-filter')?.value || 'all';

        const response = await fetch(
            `${API_BASE}/admin/v2/users?search=${search}&status=${status}&kyc_status=${kyc}`,
            { headers: { 'Authorization': `Bearer ${authToken}` } }
        );
        
        const data = await response.json();
        console.log('Users data received:', data);
        
        // Check for error response
        if (data.error) {
            console.error('Users API error:', data.error);
            return;
        }
        
        if (!response.ok) {
            console.error('Users API error:', response.status, response.statusText);
            return;
        }

        const tbody = document.querySelector('#users-table tbody');
        tbody.innerHTML = '';

        if (!data.users || !Array.isArray(data.users)) {
            console.error('Invalid users data:', data);
            tbody.innerHTML = '<tr><td colspan="8">No users found</td></tr>';
            return;
        }

        if (data.users.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8">No users found</td></tr>';
            return;
        }

        data.users.forEach(u => {
            const row = `
                <tr>
                    <td>#${u.id}</td>
                    <td>${u.full_name || 'N/A'}</td>
                    <td>${u.phone}</td>
                    <td>${u.email || 'N/A'}</td>
                    <td><span class="status-badge status-${u.kyc_status}">${u.kyc_status}</span></td>
                    <td>${parseFloat(u.balance || 0).toFixed(2)} INR</td>
                    <td><span class="status-badge status-${u.status}">${u.status}</span></td>
                    <td>
                        <button class="btn btn-primary" onclick="viewUser(${u.id})">View</button>
                        <button class="btn ${u.status === 'active' ? 'btn-reject' : 'btn-approve'}" 
                                onclick="toggleUserStatus(${u.id})">
                            ${u.status === 'active' ? 'Block' : 'Unblock'}
                        </button>
                    </td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (error) {
        console.error('Load users error:', error);
    }
}

// Transactions
async function loadTransactions() {
    try {
        const status = document.getElementById('transaction-status-filter')?.value || 'all';
        
        const response = await fetch(
            `${API_BASE}/admin/v2/transactions?status=${status}`,
            { headers: { 'Authorization': `Bearer ${authToken}` } }
        );
        
        const data = await response.json();
        console.log('Transactions data received:', data);
        
        // Check for error response
        if (data.error) {
            console.error('Transactions API error:', data.error);
            return;
        }
        
        if (!response.ok) {
            console.error('Transactions API error:', response.status, response.statusText);
            return;
        }

        const tbody = document.querySelector('#transactions-table tbody');
        tbody.innerHTML = '';

        if (!data.transactions || !Array.isArray(data.transactions)) {
            console.error('Invalid transactions data:', data);
            tbody.innerHTML = '<tr><td colspan="8">No transactions found</td></tr>';
            return;
        }

        if (data.transactions.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8">No transactions found</td></tr>';
            return;
        }

        data.transactions.forEach(t => {
            const row = `
                <tr>
                    <td>#${t.id}</td>
                    <td>${t.users?.full_name || 'N/A'}</td>
                    <td>${parseFloat(t.bdt_amount).toLocaleString()} BDT</td>
                    <td>${parseFloat(t.inr_amount).toLocaleString()} INR</td>
                    <td>${parseFloat(t.exchange_rate).toFixed(4)}</td>
                    <td><span class="status-badge status-${t.status}">${t.status}</span></td>
                    <td>${new Date(t.created_at).toLocaleString()}</td>
                    <td>
                        <button class="btn btn-primary" onclick="viewTransaction(${t.id})">View</button>
                        ${t.status === 'pending' ? `
                            <button class="btn btn-approve" onclick="updateTransactionStatus(${t.id}, 'completed')">Approve</button>
                            <button class="btn btn-reject" onclick="updateTransactionStatus(${t.id}, 'rejected')">Reject</button>
                        ` : ''}
                    </td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (error) {
        console.error('Load transactions error:', error);
    }
}

async function updateTransactionStatus(id, status) {
    const note = prompt(`Enter admin note for ${status}:`);
    if (!note) return;

    try {
        const response = await fetch(`${API_BASE}/admin/v2/transactions/${id}/status`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ status, admin_note: note })
        });

        if (response.ok) {
            showNotification(`Transaction ${status}`, 'success');
            loadTransactions();
        }
    } catch (error) {
        console.error('Update transaction error:', error);
        showNotification('Failed to update transaction', 'error');
    }
}

// KYC
async function loadKYCRequests() {
    try {
        const response = await fetch(`${API_BASE}/admin/v2/kyc/pending`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        
        const data = await response.json();
        console.log('KYC data received:', data);
        
        // Check for error response
        if (data.error) {
            console.error('KYC API error:', data.error);
            return;
        }
        
        if (!response.ok) {
            console.error('KYC API error:', response.status, response.statusText);
            return;
        }

        const container = document.getElementById('kyc-list');
        container.innerHTML = '';

        if (!data.users || !Array.isArray(data.users)) {
            console.error('Invalid KYC data:', data);
            container.innerHTML = '<p>No pending KYC requests</p>';
            return;
        }

        if (data.users.length === 0) {
            container.innerHTML = '<p>No pending KYC requests</p>';
            return;
        }

        data.users.forEach(u => {
            const card = `
                <div class="kyc-card">
                    <h3>${u.full_name}</h3>
                    <p>Phone: ${u.phone}</p>
                    <p>Email: ${u.email || 'N/A'}</p>
                    <div class="kyc-actions">
                        <button class="btn btn-approve" onclick="reviewKYC(${u.id}, 'approved')">Approve</button>
                        <button class="btn btn-reject" onclick="reviewKYC(${u.id}, 'rejected')">Reject</button>
                    </div>
                </div>
            `;
            container.innerHTML += card;
        });
    } catch (error) {
        console.error('Load KYC error:', error);
    }
}

async function reviewKYC(userId, status) {
    let reason = null;
    if (status === 'rejected') {
        reason = prompt('Enter rejection reason:');
        if (!reason) return;
    }

    try {
        const response = await fetch(`${API_BASE}/admin/v2/kyc/${userId}/review`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ status, rejection_reason: reason })
        });

        if (response.ok) {
            showNotification(`KYC ${status}`, 'success');
            loadKYCRequests();
        }
    } catch (error) {
        console.error('Review KYC error:', error);
    }
}

// Exchange Rate
async function loadExchangeRate() {
    try {
        const response = await fetch(`${API_BASE}/exchange/rate`);
        const data = await response.json();

        document.getElementById('current-rate-display').textContent = parseFloat(data.base_rate).toFixed(4);
        document.getElementById('rate-last-update').textContent = new Date(data.updated_at).toLocaleString();
    } catch (error) {
        console.error('Load rate error:', error);
    }
}

async function updateRate(event) {
    event.preventDefault();
    const newRate = document.getElementById('new-rate').value;

    try {
        const response = await fetch(`${API_BASE}/admin/v2/exchange-rate/update`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ base_rate: newRate })
        });

        if (response.ok) {
            showNotification('Rate updated successfully', 'success');
            loadExchangeRate();
            document.getElementById('new-rate').value = '';
        }
    } catch (error) {
        console.error('Update rate error:', error);
        showNotification('Failed to update rate', 'error');
    }
}

// Notifications
async function sendNotification(event) {
    event.preventDefault();
    
    const userId = document.getElementById('notif-user-id').value;
    const title = document.getElementById('notif-title').value;
    const message = document.getElementById('notif-message').value;
    const type = document.getElementById('notif-type').value;

    const endpoint = userId ? '/notifications/send' : '/announcements/broadcast';
    const body = userId ? { user_id: userId, title, message, type } : { title, message, type };

    try {
        const response = await fetch(`${API_BASE}/admin/v2${endpoint}`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(body)
        });

        if (response.ok) {
            showNotification('Notification sent', 'success');
            event.target.reset();
        }
    } catch (error) {
        console.error('Send notification error:', error);
    }
}

// Analytics
async function loadAnalytics() {
    const period = document.getElementById('analytics-period')?.value || '7d';
    
    try {
        const response = await fetch(`${API_BASE}/admin/v2/analytics?period=${period}`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        const data = await response.json();

        // Render charts with data
        console.log('Analytics data:', data);
    } catch (error) {
        console.error('Load analytics error:', error);
    }
}

// Logs
async function loadLogs() {
    try {
        const response = await fetch(`${API_BASE}/admin/v2/logs`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        const data = await response.json();
        console.log('Logs data received:', data);
        
        // Check for error response
        if (data.error) {
            console.error('Logs API error:', data.error);
            return;
        }

        const tbody = document.querySelector('#logs-table tbody');
        tbody.innerHTML = '';

        if (!data.logs || !Array.isArray(data.logs)) {
            console.error('Invalid logs data:', data);
            tbody.innerHTML = '<tr><td colspan="5">No logs found</td></tr>';
            return;
        }

        if (data.logs.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5">No logs found</td></tr>';
            return;
        }

        data.logs.forEach(log => {
            const row = `
                <tr>
                    <td>${new Date(log.created_at).toLocaleString()}</td>
                    <td>${log.admin?.full_name || 'System'}</td>
                    <td>${log.action}</td>
                    <td>${log.target_id || 'N/A'}</td>
                    <td>${JSON.stringify(log.details || {})}</td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (error) {
        console.error('Load logs error:', error);
    }
}

// Utilities
function getUserIdFromToken() {
    try {
        const payload = JSON.parse(atob(authToken.split('.')[1]));
        return payload.userId;
    } catch {
        return null;
    }
}

function showNotification(message, type = 'info') {
    // Create a simple toast notification
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        background: ${type === 'error' ? '#f44336' : type === 'success' ? '#4caf50' : '#2196f3'};
        color: white;
        border-radius: 4px;
        z-index: 10000;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    `;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.remove();
    }, 3000);
}

function logout() {
    localStorage.removeItem('admin_token');
    window.location.href = 'login.html';
}

function setupEventListeners() {
    // Search users
    document.getElementById('user-search')?.addEventListener('input', debounce(loadUsers, 500));
    
    // Filter users
    document.getElementById('user-status-filter')?.addEventListener('change', loadUsers);
    document.getElementById('kyc-status-filter')?.addEventListener('change', loadUsers);
    
    // Filter transactions
    document.getElementById('transaction-status-filter')?.addEventListener('change', loadTransactions);
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

async function viewUser(userId) {
    // Implement user details modal
    console.log('View user:', userId);
}

async function viewTransaction(transactionId) {
    // Implement transaction details modal
    console.log('View transaction:', transactionId);
}

async function toggleUserStatus(userId) {
    try {
        const response = await fetch(`${API_BASE}/admin/v2/users/${userId}/toggle-status`, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${authToken}` }
        });

        if (response.ok) {
            showNotification('User status updated', 'success');
            loadUsers();
        }
    } catch (error) {
        console.error('Toggle user status error:', error);
    }
}

// Support Tickets Management
let currentTicketId = null;
let supportSearchTimeout = null;

async function loadSupportTickets() {
    try {
        const status = document.getElementById('support-status-filter')?.value || 'all';
        const priority = document.getElementById('support-priority-filter')?.value || 'all';
        const category = document.getElementById('support-category-filter')?.value || 'all';
        const search = document.getElementById('support-search')?.value || '';

        const response = await fetch(
            `${API_BASE}/support/tickets?status=${status}&priority=${priority}&category=${category}&search=${search}`,
            { headers: { 'Authorization': `Bearer ${authToken}` } }
        );
        
        const data = await response.json();
        console.log('Support tickets data:', data);
        
        if (data.error) {
            console.error('Support tickets API error:', data.error);
            return;
        }

        const tbody = document.querySelector('#support-table tbody');
        tbody.innerHTML = '';

        if (!data.tickets || !Array.isArray(data.tickets)) {
            tbody.innerHTML = '<tr><td colspan="8">No tickets found</td></tr>';
            return;
        }

        if (data.tickets.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8">No tickets found</td></tr>';
            return;
        }

        data.tickets.forEach(t => {
            const priorityClass = t.priority === 'high' ? 'priority-high' : t.priority === 'low' ? 'priority-low' : 'priority-normal';
            const row = `
                <tr>
                    <td>#${t.id}</td>
                    <td>${t.users?.full_name || 'N/A'}</td>
                    <td>${t.subject}</td>
                    <td><span class="category-badge">${t.category}</span></td>
                    <td><span class="priority-badge ${priorityClass}">${t.priority}</span></td>
                    <td><span class="status-badge status-${t.status}">${t.status}</span></td>
                    <td>${new Date(t.created_at).toLocaleString()}</td>
                    <td>
                        <button class="btn btn-primary" onclick="viewTicket(${t.id})">View</button>
                    </td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (error) {
        console.error('Load support tickets error:', error);
        showNotification('Failed to load support tickets', 'error');
    }
}

async function loadSupportStats() {
    try {
        const response = await fetch(`${API_BASE}/support/stats`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        
        const stats = await response.json();
        
        if (!stats.error) {
            document.getElementById('support-open').textContent = stats.open || 0;
            document.getElementById('support-replied').textContent = stats.replied || 0;
            document.getElementById('support-closed').textContent = stats.closed || 0;
            document.getElementById('support-high').textContent = stats.high_priority || 0;
            document.getElementById('support-badge').textContent = stats.open || 0;
        }
    } catch (error) {
        console.error('Load support stats error:', error);
    }
}

async function viewTicket(ticketId) {
    try {
        currentTicketId = ticketId;
        
        const response = await fetch(`${API_BASE}/support/tickets/${ticketId}`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        
        const data = await response.json();
        
        if (data.error) {
            showNotification('Failed to load ticket', 'error');
            return;
        }

        const ticket = data.ticket;
        const messages = data.messages;

        // Update modal content
        document.getElementById('ticket-subject').textContent = ticket.subject;
        document.getElementById('ticket-user').innerHTML = `<strong>User:</strong> ${ticket.users?.full_name || 'N/A'}`;
        document.getElementById('ticket-category').innerHTML = `<strong>Category:</strong> ${ticket.category}`;
        document.getElementById('ticket-priority').innerHTML = `<strong>Priority:</strong> ${ticket.priority}`;
        document.getElementById('ticket-status').innerHTML = `<strong>Status:</strong> ${ticket.status}`;
        
        // Set priority dropdown
        document.getElementById('ticket-priority-update').value = ticket.priority;

        // Load messages
        const messagesContainer = document.getElementById('ticket-messages');
        messagesContainer.innerHTML = '';

        messages.forEach(msg => {
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${msg.sender_type}`;
            messageDiv.innerHTML = `
                <div class="message-header">
                    <strong>${msg.sender_type === 'admin' ? 'Admin' : ticket.users?.full_name}</strong>
                    <span class="message-time">${new Date(msg.created_at).toLocaleString()}</span>
                </div>
                <div class="message-body">${msg.message}</div>
            `;
            messagesContainer.appendChild(messageDiv);
        });

        // Scroll to bottom
        messagesContainer.scrollTop = messagesContainer.scrollHeight;

        // Show modal
        document.getElementById('support-modal').classList.add('active');
    } catch (error) {
        console.error('View ticket error:', error);
        showNotification('Failed to load ticket details', 'error');
    }
}

async function sendReply() {
    const message = document.getElementById('reply-message').value.trim();
    
    if (!message) {
        showNotification('Please enter a reply message', 'warning');
        return;
    }

    try {
        const response = await fetch(`${API_BASE}/support/tickets/${currentTicketId}/reply`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ message })
        });

        if (response.ok) {
            showNotification('Reply sent successfully', 'success');
            document.getElementById('reply-message').value = '';
            
            // Update status if needed
            const status = document.getElementById('reply-status').value;
            if (status === 'closed') {
                await updateTicketStatus(currentTicketId, 'closed');
            }
            
            // Reload ticket
            viewTicket(currentTicketId);
            loadSupportTickets();
            loadSupportStats();
        } else {
            showNotification('Failed to send reply', 'error');
        }
    } catch (error) {
        console.error('Send reply error:', error);
        showNotification('Failed to send reply', 'error');
    }
}

async function updateTicketStatus(ticketId, status) {
    try {
        const response = await fetch(`${API_BASE}/support/tickets/${ticketId}/status`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ status })
        });

        if (response.ok) {
            showNotification(`Ticket ${status}`, 'success');
            return true;
        }
        return false;
    } catch (error) {
        console.error('Update ticket status error:', error);
        return false;
    }
}

async function updateTicketPriority() {
    const priority = document.getElementById('ticket-priority-update').value;
    
    try {
        const response = await fetch(`${API_BASE}/support/tickets/${currentTicketId}/priority`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ priority })
        });

        if (response.ok) {
            showNotification('Priority updated', 'success');
            loadSupportTickets();
        }
    } catch (error) {
        console.error('Update priority error:', error);
        showNotification('Failed to update priority', 'error');
    }
}

async function closeTicket() {
    if (!confirm('Are you sure you want to close this ticket?')) {
        return;
    }

    const success = await updateTicketStatus(currentTicketId, 'closed');
    if (success) {
        closeModal('support-modal');
        loadSupportTickets();
        loadSupportStats();
    }
}

function debounceSearch() {
    clearTimeout(supportSearchTimeout);
    supportSearchTimeout = setTimeout(() => {
        loadSupportTickets();
    }, 500);
}


// Mobile Menu Functions
function toggleMobileMenu() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.querySelector('.mobile-overlay');
    const menuBtn = document.querySelector('.mobile-menu-toggle');
    
    sidebar.classList.toggle('mobile-open');
    overlay.classList.toggle('active');
    
    // Change icon
    const icon = menuBtn.querySelector('i');
    if (sidebar.classList.contains('mobile-open')) {
        icon.className = 'fas fa-times';
    } else {
        icon.className = 'fas fa-bars';
    }
}

function closeMobileMenu() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.querySelector('.mobile-overlay');
    const menuBtn = document.querySelector('.mobile-menu-toggle');
    
    sidebar.classList.remove('mobile-open');
    overlay.classList.remove('active');
    
    // Reset icon
    const icon = menuBtn.querySelector('i');
    icon.className = 'fas fa-bars';
}

// Close mobile menu when navigating
const originalNavigateToPage = navigateToPage;
navigateToPage = function(page) {
    closeMobileMenu();
    originalNavigateToPage(page);
};

// Handle window resize
let resizeTimer;
window.addEventListener('resize', () => {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(() => {
        if (window.innerWidth > 768) {
            closeMobileMenu();
        }
    }, 250);
});

// Prevent body scroll when mobile menu is open
document.addEventListener('DOMContentLoaded', () => {
    const sidebar = document.getElementById('sidebar');
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            if (mutation.attributeName === 'class') {
                if (sidebar.classList.contains('mobile-open')) {
                    document.body.style.overflow = 'hidden';
                } else {
                    document.body.style.overflow = '';
                }
            }
        });
    });
    
    observer.observe(sidebar, { attributes: true });
});


// Mobile table scroll detection
function initMobileTableScroll() {
    const tableContainers = document.querySelectorAll('.table-container');
    
    tableContainers.forEach(container => {
        container.addEventListener('scroll', () => {
            if (container.scrollLeft > 10) {
                container.classList.add('scrolled');
            } else {
                container.classList.remove('scrolled');
            }
        });
    });
}

// Call on page load and when content changes
document.addEventListener('DOMContentLoaded', initMobileTableScroll);

// Reinitialize after loading new content
const originalLoadUsers = loadUsers;
loadUsers = async function() {
    await originalLoadUsers();
    initMobileTableScroll();
};

const originalLoadTransactions = loadTransactions;
loadTransactions = async function() {
    await originalLoadTransactions();
    initMobileTableScroll();
};

const originalLoadSupportTickets = loadSupportTickets;
loadSupportTickets = async function() {
    await originalLoadSupportTickets();
    initMobileTableScroll();
};

// Add touch-friendly improvements
document.addEventListener('DOMContentLoaded', () => {
    // Prevent double-tap zoom on buttons
    let lastTouchEnd = 0;
    document.addEventListener('touchend', (event) => {
        const now = Date.now();
        if (now - lastTouchEnd <= 300) {
            event.preventDefault();
        }
        lastTouchEnd = now;
    }, false);
    
    // Add haptic feedback for mobile (if supported)
    if ('vibrate' in navigator) {
        document.querySelectorAll('.btn, .nav-item').forEach(element => {
            element.addEventListener('click', () => {
                navigator.vibrate(10); // Short vibration
            });
        });
    }
});

// Mobile-friendly notification positioning
const originalShowNotification = showNotification;
showNotification = function(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    
    // Check if mobile
    const isMobile = window.innerWidth <= 768;
    
    toast.style.cssText = `
        position: fixed;
        ${isMobile ? 'bottom: 20px; left: 50%; transform: translateX(-50%); width: calc(100% - 40px); max-width: 400px;' : 'top: 20px; right: 20px;'}
        padding: ${isMobile ? '16px' : '15px 20px'};
        background: ${type === 'error' ? '#f44336' : type === 'success' ? '#4caf50' : '#2196f3'};
        color: white;
        border-radius: ${isMobile ? '12px' : '4px'};
        z-index: 10000;
        box-shadow: 0 ${isMobile ? '4px 12px' : '2px 5px'} rgba(0,0,0,0.2);
        font-size: ${isMobile ? '15px' : '14px'};
        text-align: center;
        animation: ${isMobile ? 'slideUpFade' : 'fadeIn'} 0.3s ease;
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = isMobile ? 'slideDownFade 0.3s ease' : 'fadeOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
};

// Add animation styles
const style = document.createElement('style');
style.textContent = `
    @keyframes slideUpFade {
        from {
            opacity: 0;
            transform: translate(-50%, 20px);
        }
        to {
            opacity: 1;
            transform: translate(-50%, 0);
        }
    }
    
    @keyframes slideDownFade {
        from {
            opacity: 1;
            transform: translate(-50%, 0);
        }
        to {
            opacity: 0;
            transform: translate(-50%, 20px);
        }
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    
    @keyframes fadeOut {
        from { opacity: 1; }
        to { opacity: 0; }
    }
`;
document.head.appendChild(style);

// Add pull-to-refresh visual feedback (optional)
let touchStartY = 0;
let touchEndY = 0;

document.addEventListener('touchstart', (e) => {
    touchStartY = e.touches[0].clientY;
}, { passive: true });

document.addEventListener('touchmove', (e) => {
    touchEndY = e.touches[0].clientY;
    
    // If at top of page and pulling down
    if (window.scrollY === 0 && touchEndY > touchStartY + 50) {
        // Visual feedback only - actual refresh would need more implementation
        const indicator = document.querySelector('.refresh-indicator');
        if (indicator) {
            indicator.classList.add('active');
        }
    }
}, { passive: true });

document.addEventListener('touchend', () => {
    const indicator = document.querySelector('.refresh-indicator');
    if (indicator) {
        indicator.classList.remove('active');
    }
    touchStartY = 0;
    touchEndY = 0;
}, { passive: true });

// Optimize performance on mobile
if (window.innerWidth <= 768) {
    // Reduce animation complexity on mobile
    document.documentElement.style.setProperty('--animation-duration', '0.2s');
    
    // Use passive event listeners for better scroll performance
    document.addEventListener('scroll', () => {
        // Scroll handling
    }, { passive: true });
}

// Add orientation change handler
window.addEventListener('orientationchange', () => {
    // Close mobile menu on orientation change
    closeMobileMenu();
    
    // Recalculate layouts after orientation change
    setTimeout(() => {
        window.dispatchEvent(new Event('resize'));
    }, 100);
});

// Service Worker registration for PWA (optional)
if ('serviceWorker' in navigator && window.innerWidth <= 768) {
    // Could register a service worker for offline support
    console.log('Mobile device detected - PWA features available');
}

// Admin Dashboard JavaScript
const API_BASE = 'http://localhost:3000/api';
let socket;
let authToken = localStorage.getItem('admin_token');
let currentTransactionId = null;

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
    socket = io('http://localhost:3000');
    
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
        loadDashboard();
    });

    socket.on('user_event', (data) => {
        console.log('User event:', data);
        if (data.type === 'INSERT') {
            showNotification('New user registered', 'success');
        }
        loadDashboard();
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
    try {
        const response = await fetch(`${API_BASE}/admin/v2/dashboard`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        
        const data = await response.json();
        console.log('Dashboard data received:', data);
        
        // Check for API error response
        if (data.error) {
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

        // Check if data has the expected structure
        if (!data || !data.overview) {
            console.error('Invalid dashboard data structure:', data);
            showNotification('Failed to load dashboard data', 'error');
            return;
        }

        // Update stats
        document.getElementById('total-users').textContent = data.overview.totalUsers || 0;
        document.getElementById('active-users').textContent = data.overview.activeUsers || 0;
        document.getElementById('pending-transactions').textContent = data.overview.pendingTransactions || 0;
        document.getElementById('today-volume').textContent = parseFloat(data.overview.totalVolume || 0).toLocaleString();
        document.getElementById('kyc-badge').textContent = data.overview.pendingKYC || 0;

        // Load recent transactions
        if (data.recentTransactions && Array.isArray(data.recentTransactions)) {
            loadRecentTransactions(data.recentTransactions);
        }
    } catch (error) {
        console.error('Load dashboard error:', error);
        showNotification('Error loading dashboard', 'error');
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

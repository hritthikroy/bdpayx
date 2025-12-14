// Modern Mobile-First Admin Dashboard
const API_BASE = 'http://localhost:8081/api';
let authToken = localStorage.getItem('admin_token');
let socket;
let currentPage = 'dashboard';
let currentTransactionId = null;

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    if (!authToken) {
        window.location.href = 'login-modern.html';
        return;
    }

    initializeSocket();
    loadDashboard();
    setupEventListeners();
});

// Socket.IO Connection
function initializeSocket() {
    socket = io('http://localhost:8081');
    
    socket.on('connect', () => {
        console.log('Connected to server');
        socket.emit('authenticate', {
            userId: getUserIdFromToken(),
            role: 'admin'
        });
    });

    socket.on('admin_stats', (data) => {
        updateDashboardStats(data);
    });

    socket.on('transaction_event', (data) => {
        showToast('New transaction received', 'info');
        if (currentPage === 'dashboard' || currentPage === 'transactions') {
            loadCurrentPage();
        }
    });

    socket.on('new_support_ticket', (data) => {
        showToast('New support ticket', 'info');
        if (currentPage === 'support') {
            loadSupport();
        }
    });
}

// Navigation
function navigateTo(page) {
    event?.preventDefault();
    currentPage = page;
    
    // Hide all pages
    document.querySelectorAll('.page').forEach(p => {
        p.style.display = 'none';
    });
    
    // Show selected page
    document.getElementById(`${page}-page`).style.display = 'block';
    
    // Update bottom nav
    document.querySelectorAll('.nav-item-mobile').forEach(item => {
        item.classList.remove('active');
    });
    document.querySelector(`[data-page="${page}"]`)?.classList.add('active');
    
    // Load page data
    loadCurrentPage();
    
    // Scroll to top
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function loadCurrentPage() {
    switch(currentPage) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'users':
            loadUsers();
            break;
        case 'transactions':
            loadTransactions();
            break;
        case 'support':
            loadSupport();
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
        
        if (data.error) {
            showToast(data.error, 'error');
            return;
        }

        // Update stats
        const overview = data.overview || {};
        document.getElementById('total-users').textContent = overview.totalUsers || 0;
        document.getElementById('active-users').textContent = overview.activeUsers || 0;
        document.getElementById('pending-tx').textContent = overview.pendingTransactions || 0;
        document.getElementById('today-volume').textContent = formatNumber(overview.totalVolume || 0);

        // Load recent transactions
        if (data.recentTransactions) {
            loadRecentTransactions(data.recentTransactions);
        }
    } catch (error) {
        console.error('Load dashboard error:', error);
        showToast('Failed to load dashboard', 'error');
    }
}

function loadRecentTransactions(transactions) {
    const container = document.getElementById('recent-transactions-list');
    container.innerHTML = '';

    transactions.slice(0, 5).forEach(tx => {
        const statusClass = tx.status === 'completed' ? 'success' : 
                          tx.status === 'pending' ? 'warning' : 'danger';
        
        const item = `
            <a href="#" class="list-item-modern" onclick="viewTransaction(${tx.id})">
                <div class="list-item-icon">
                    <i class="fas fa-exchange-alt"></i>
                </div>
                <div class="list-item-content">
                    <div class="list-item-title">${tx.users?.full_name || 'User'}</div>
                    <div class="list-item-subtitle">${formatNumber(tx.bdt_amount)} BDT → ${formatNumber(tx.inr_amount)} INR</div>
                </div>
                <div class="list-item-badge ${statusClass}">${tx.status}</div>
            </a>
        `;
        container.innerHTML += item;
    });
}

// Users
async function loadUsers() {
    try {
        const search = document.getElementById('user-search')?.value || '';
        const response = await fetch(
            `${API_BASE}/admin/v2/users?search=${search}`,
            { headers: { 'Authorization': `Bearer ${authToken}` } }
        );
        
        const data = await response.json();
        
        if (data.error) {
            showToast(data.error, 'error');
            return;
        }

        const container = document.getElementById('users-list');
        container.innerHTML = '';

        if (!data.users || data.users.length === 0) {
            container.innerHTML = '<div style="padding: 24px; text-align: center; color: var(--text-secondary);">No users found</div>';
            return;
        }

        data.users.forEach(user => {
            const statusClass = user.status === 'active' ? 'success' : 'danger';
            const item = `
                <div class="list-item-modern">
                    <div class="list-item-icon">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="list-item-content">
                        <div class="list-item-title">${user.full_name}</div>
                        <div class="list-item-subtitle">${user.phone}</div>
                    </div>
                    <div class="list-item-badge ${statusClass}">${user.status}</div>
                </div>
            `;
            container.innerHTML += item;
        });
    } catch (error) {
        console.error('Load users error:', error);
        showToast('Failed to load users', 'error');
    }
}

// Transactions
async function loadTransactions() {
    try {
        const status = document.getElementById('tx-filter')?.value || 'all';
        const response = await fetch(
            `${API_BASE}/admin/v2/transactions?status=${status}`,
            { headers: { 'Authorization': `Bearer ${authToken}` } }
        );
        
        const data = await response.json();
        
        if (data.error) {
            showToast(data.error, 'error');
            return;
        }

        const container = document.getElementById('transactions-list');
        container.innerHTML = '';

        if (!data.transactions || data.transactions.length === 0) {
            container.innerHTML = '<div style="padding: 24px; text-align: center; color: var(--text-secondary);">No transactions found</div>';
            return;
        }

        data.transactions.forEach(tx => {
            const statusClass = tx.status === 'completed' ? 'success' : 
                              tx.status === 'pending' ? 'warning' : 'danger';
            
            const item = `
                <a href="#" class="list-item-modern" onclick="viewTransaction(${tx.id})">
                    <div class="list-item-icon">
                        <i class="fas fa-exchange-alt"></i>
                    </div>
                    <div class="list-item-content">
                        <div class="list-item-title">${tx.users?.full_name || 'User'}</div>
                        <div class="list-item-subtitle">${formatNumber(tx.bdt_amount)} BDT → ${formatNumber(tx.inr_amount)} INR</div>
                    </div>
                    <div class="list-item-badge ${statusClass}">${tx.status}</div>
                </a>
            `;
            container.innerHTML += item;
        });
    } catch (error) {
        console.error('Load transactions error:', error);
        showToast('Failed to load transactions', 'error');
    }
}

// Support
async function loadSupport() {
    try {
        const status = document.getElementById('support-filter')?.value || 'all';
        const response = await fetch(
            `${API_BASE}/support/tickets?status=${status}`,
            { headers: { 'Authorization': `Bearer ${authToken}` } }
        );
        
        const data = await response.json();
        
        if (data.error) {
            showToast(data.error, 'error');
            return;
        }

        const container = document.getElementById('support-list');
        container.innerHTML = '';

        if (!data.tickets || data.tickets.length === 0) {
            container.innerHTML = '<div style="padding: 24px; text-align: center; color: var(--text-secondary);">No tickets found</div>';
            return;
        }

        data.tickets.forEach(ticket => {
            const statusClass = ticket.status === 'closed' ? 'success' : 
                              ticket.status === 'replied' ? 'info' : 'warning';
            const priorityIcon = ticket.priority === 'high' ? '🔴' : 
                               ticket.priority === 'normal' ? '🟡' : '🟢';
            
            const item = `
                <a href="#" class="list-item-modern" onclick="viewTicket(${ticket.id})">
                    <div class="list-item-icon">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                    <div class="list-item-content">
                        <div class="list-item-title">${priorityIcon} ${ticket.subject}</div>
                        <div class="list-item-subtitle">${ticket.users?.full_name || 'User'}</div>
                    </div>
                    <div class="list-item-badge ${statusClass}">${ticket.status}</div>
                </a>
            `;
            container.innerHTML += item;
        });
    } catch (error) {
        console.error('Load support error:', error);
        showToast('Failed to load support tickets', 'error');
    }
}

// View Transaction
async function viewTransaction(id) {
    event?.preventDefault();
    currentTransactionId = id;
    
    try {
        const response = await fetch(`${API_BASE}/admin/v2/transactions/${id}`, {
            headers: { 'Authorization': `Bearer ${authToken}` }
        });
        
        const data = await response.json();
        
        if (data.error) {
            showToast(data.error, 'error');
            return;
        }

        const tx = data.transaction;
        const details = `
            <div style="display: flex; flex-direction: column; gap: 16px;">
                <div>
                    <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">User</div>
                    <div style="font-size: 16px; font-weight: 600;">${tx.users?.full_name || 'N/A'}</div>
                </div>
                <div>
                    <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Amount</div>
                    <div style="font-size: 16px; font-weight: 600;">${formatNumber(tx.bdt_amount)} BDT → ${formatNumber(tx.inr_amount)} INR</div>
                </div>
                <div>
                    <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Exchange Rate</div>
                    <div style="font-size: 16px; font-weight: 600;">${tx.exchange_rate}</div>
                </div>
                <div>
                    <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Status</div>
                    <div><span class="badge-modern badge-${tx.status === 'completed' ? 'success' : tx.status === 'pending' ? 'warning' : 'danger'}">${tx.status}</span></div>
                </div>
                <div>
                    <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Date</div>
                    <div style="font-size: 16px; font-weight: 600;">${new Date(tx.created_at).toLocaleString()}</div>
                </div>
            </div>
        `;
        
        document.getElementById('transaction-details').innerHTML = details;
        openModal('transaction-modal');
    } catch (error) {
        console.error('View transaction error:', error);
        showToast('Failed to load transaction', 'error');
    }
}

// Approve Transaction
async function approveTransaction() {
    if (!currentTransactionId) return;
    
    try {
        const response = await fetch(`${API_BASE}/admin/v2/transactions/${currentTransactionId}/status`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ status: 'completed', admin_note: 'Approved via mobile' })
        });

        if (response.ok) {
            showToast('Transaction approved!', 'success');
            closeModal('transaction-modal');
            loadCurrentPage();
        } else {
            showToast('Failed to approve transaction', 'error');
        }
    } catch (error) {
        console.error('Approve transaction error:', error);
        showToast('Failed to approve transaction', 'error');
    }
}

// Reject Transaction
async function rejectTransaction() {
    if (!currentTransactionId) return;
    
    try {
        const response = await fetch(`${API_BASE}/admin/v2/transactions/${currentTransactionId}/status`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ status: 'rejected', admin_note: 'Rejected via mobile' })
        });

        if (response.ok) {
            showToast('Transaction rejected', 'warning');
            closeModal('transaction-modal');
            loadCurrentPage();
        } else {
            showToast('Failed to reject transaction', 'error');
        }
    } catch (error) {
        console.error('Reject transaction error:', error);
        showToast('Failed to reject transaction', 'error');
    }
}

// Modal Functions
function openModal(modalId) {
    document.getElementById(modalId).classList.add('active');
    document.body.style.overflow = 'hidden';
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
    document.body.style.overflow = '';
}

// Toast Notifications
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast-modern toast-${type}`;
    toast.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : type === 'warning' ? 'exclamation-triangle' : 'info-circle'}"></i>
        <div style="flex: 1;">${message}</div>
    `;
    
    document.body.appendChild(toast);
    
    // Haptic feedback
    if ('vibrate' in navigator) {
        navigator.vibrate(50);
    }
    
    setTimeout(() => {
        toast.style.animation = 'slideDown 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Utility Functions
function formatNumber(num) {
    return parseFloat(num || 0).toLocaleString('en-US', { maximumFractionDigits: 2 });
}

function getUserIdFromToken() {
    try {
        const payload = JSON.parse(atob(authToken.split('.')[1]));
        return payload.userId;
    } catch {
        return null;
    }
}

function logout() {
    event?.preventDefault();
    localStorage.removeItem('admin_token');
    window.location.href = 'login-modern.html';
}

// Event Listeners
function setupEventListeners() {
    // Search users
    document.getElementById('user-search')?.addEventListener('input', debounce(loadUsers, 500));
    
    // Close modals on backdrop click
    document.querySelectorAll('.modal-modern').forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeModal(modal.id);
            }
        });
    });
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func(...args), wait);
    };
}

function filterTransactions() {
    loadTransactions();
}

function filterSupport() {
    loadSupport();
}

// Placeholder functions
function toggleMenu() {
    showToast('Menu feature coming soon!', 'info');
}

function showNotifications() {
    showToast('Notifications feature coming soon!', 'info');
}

function showProfile() {
    event?.preventDefault();
    showToast('Profile feature coming soon!', 'info');
}

function showNotificationSettings() {
    event?.preventDefault();
    showToast('Notification settings coming soon!', 'info');
}

function showSecurity() {
    event?.preventDefault();
    showToast('Security settings coming soon!', 'info');
}

function viewTicket(id) {
    event?.preventDefault();
    showToast('Ticket details coming soon!', 'info');
}

// Add slideDown animation
const style = document.createElement('style');
style.textContent = `
    @keyframes slideDown {
        from {
            transform: translateY(0);
            opacity: 1;
        }
        to {
            transform: translateY(20px);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

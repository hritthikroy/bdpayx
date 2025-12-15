# 🔐 BDPayX Admin System - Complete Guide

## 🎉 Powerful Admin Backend & Dashboard

Your admin system includes:
- ✅ Real-time monitoring with Socket.IO
- ✅ Complete user management
- ✅ Transaction control & approval
- ✅ KYC verification system
- ✅ Exchange rate management
- ✅ Notifications & announcements
- ✅ Analytics & reports
- ✅ Activity logging
- ✅ System settings control

---

## 🚀 Quick Start

### 1. Setup Database

Run the admin schema:
```bash
psql -U your_user -d currency_exchange -f backend/src/database/admin-schema.sql
```

Or if using Supabase, run the SQL in the SQL Editor.

### 2. Start Admin System

```bash
./START_ADMIN.sh
```

This starts:
- Backend API on port 3000
- Admin Dashboard on port 8081

### 3. Access Admin Dashboard

Open: **http://localhost:8081**

Default login:
- Phone: `+8801700000000`
- Password: `admin123`

**⚠️ Change this immediately after first login!**

---

## 📱 Admin Dashboard Features

### 1. Dashboard (Real-time)
- **Live Statistics**
  - Total users
  - Active users (real-time)
  - Pending transactions
  - Today's volume
  
- **Charts**
  - Transaction trends
  - User growth
  - Revenue analytics
  
- **Recent Activity**
  - Latest transactions
  - User registrations
  - System events

### 2. User Management
- **View All Users**
  - Search by name, phone, email
  - Filter by status (active/blocked)
  - Filter by KYC status
  - Sort by any column
  
- **User Actions**
  - View detailed profile
  - Block/Unblock users
  - Update user information
  - View transaction history
  - Check KYC documents
  
- **User Details**
  - Personal information
  - Transaction history
  - Balance & wallet
  - Activity logs

### 3. Transaction Management
- **View All Transactions**
  - Filter by status
  - Filter by date range
  - Search by user
  - Real-time updates
  
- **Transaction Actions**
  - Approve pending transactions
  - Reject with reason
  - Add admin notes
  - View payment proof
  - Track status changes
  
- **Instant Notifications**
  - New transaction alerts
  - Status change notifications
  - User notifications

### 4. KYC Verification
- **Pending Requests**
  - View all pending KYC
  - See submitted documents
  - User information
  
- **Review Actions**
  - Approve KYC
  - Reject with reason
  - Request additional documents
  
- **Notifications**
  - Auto-notify users of KYC status
  - Real-time updates

### 5. Exchange Rate Control
- **Current Rate Display**
  - Live rate
  - Last update time
  - Historical changes
  
- **Update Rate**
  - Set new rate instantly
  - Broadcast to all users
  - Log all changes
  
- **Rate History**
  - View past rates
  - Chart visualization
  - Export data

### 6. Notifications & Announcements
- **Send Notifications**
  - To specific user
  - To all users (broadcast)
  - Different types (info, success, warning, error)
  - Real-time delivery
  
- **Announcements**
  - System-wide messages
  - Scheduled announcements
  - Expiry dates
  - Active/inactive control

### 7. Analytics & Reports
- **Transaction Analytics**
  - Daily/weekly/monthly trends
  - Volume analysis
  - Revenue tracking
  - Success rates
  
- **User Analytics**
  - Growth trends
  - Active user patterns
  - Registration sources
  - Retention metrics
  
- **Custom Reports**
  - Date range selection
  - Export to CSV/PDF
  - Scheduled reports

### 8. Activity Logs
- **Admin Actions**
  - All admin activities
  - User modifications
  - Transaction approvals
  - Rate changes
  - System settings updates
  
- **Audit Trail**
  - Who did what
  - When it happened
  - What changed
  - Full details

### 9. System Settings
- **Configuration**
  - Min/max exchange amounts
  - Maintenance mode
  - KYC requirements
  - Auto-approval limits
  - Fee structures
  
- **Super Admin Only**
  - Critical settings
  - User role management
  - System parameters

---

## 🔧 Backend API Endpoints

### Admin Authentication
```
POST /api/auth/admin-login
```

### Dashboard
```
GET /api/admin/v2/dashboard
GET /api/admin/v2/analytics?period=7d
```

### User Management
```
GET /api/admin/v2/users?page=1&limit=20&search=&status=all
GET /api/admin/v2/users/:userId
PUT /api/admin/v2/users/:userId
POST /api/admin/v2/users/:userId/toggle-status
```

### Transaction Management
```
GET /api/admin/v2/transactions?status=all&page=1
PUT /api/admin/v2/transactions/:id/status
```

### KYC Management
```
GET /api/admin/v2/kyc/pending
POST /api/admin/v2/kyc/:userId/review
```

### Exchange Rate
```
POST /api/admin/v2/exchange-rate/update
GET /api/admin/v2/exchange-rate/history
```

### Notifications
```
POST /api/admin/v2/notifications/send
POST /api/admin/v2/announcements/broadcast
```

### Logs
```
GET /api/admin/v2/logs?page=1&admin_id=
```

### Settings
```
GET /api/admin/v2/settings
PUT /api/admin/v2/settings/:key
```

---

## 🔴 Real-time Features

### Socket.IO Events

**Admin Receives:**
- `admin_stats` - Real-time statistics
- `transaction_event` - New/updated transactions
- `user_event` - User registrations/updates
- `user_online` - User comes online
- `user_offline` - User goes offline
- `new_support_message` - New chat messages
- `system_stats` - Periodic system updates

**Admin Emits:**
- `authenticate` - Authenticate as admin
- `admin_request_stats` - Request current stats

**Broadcast to Users:**
- `transaction_updated` - Transaction status changed
- `kyc_updated` - KYC status changed
- `rate_updated` - Exchange rate changed
- `notification` - New notification
- `announcement` - New announcement

---

## 👥 User Roles

### User (Default)
- Can use the app
- Submit transactions
- Chat support

### Admin
- All user permissions
- View dashboard
- Manage users
- Approve transactions
- Review KYC
- Send notifications
- View analytics

### Super Admin
- All admin permissions
- Update exchange rates
- Modify system settings
- Manage other admins
- Access all logs
- Critical operations

---

## 🔒 Security Features

### Authentication
- JWT tokens
- Role-based access control
- Token expiration
- Secure password hashing

### Authorization
- Middleware protection
- Role verification
- Action logging
- IP tracking (optional)

### Audit Trail
- All admin actions logged
- User modifications tracked
- System changes recorded
- Timestamps & details

---

## 📊 Monitoring & Alerts

### Real-time Monitoring
- Active users count
- Pending transactions
- System health
- API response times

### Alerts
- High-value transactions
- Failed transactions
- Suspicious activity
- System errors

### Notifications
- Email alerts (optional)
- SMS alerts (optional)
- In-app notifications
- Desktop notifications

---

## 🎨 Dashboard Customization

### Themes
- Light/Dark mode
- Custom colors
- Logo upload
- Branding

### Widgets
- Customizable dashboard
- Drag & drop layout
- Widget preferences
- Data refresh rates

---

## 📱 Mobile Admin App

The admin dashboard is responsive and works on:
- Desktop browsers
- Tablets
- Mobile phones

For native mobile admin app, use the same Flutter codebase with admin screens.

---

## 🔧 Configuration

### Environment Variables

Add to `backend/.env`:
```env
# Admin Settings
ADMIN_SESSION_TIMEOUT=3600
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_DURATION=900

# Notifications
ENABLE_EMAIL_NOTIFICATIONS=true
ENABLE_SMS_NOTIFICATIONS=false

# Monitoring
ENABLE_REALTIME_MONITORING=true
STATS_UPDATE_INTERVAL=30000
```

---

## 🚀 Deployment

### Production Setup

1. **Secure Admin Credentials**
```sql
UPDATE users 
SET password = 'new_hashed_password'
WHERE role = 'super_admin';
```

2. **Enable HTTPS**
```javascript
// Use SSL certificates
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};

https.createServer(options, app).listen(443);
```

3. **Set Production URLs**
```javascript
// admin-dashboard/app.js
const API_BASE = 'https://api.bdpayx.com/api';
```

4. **Enable Rate Limiting**
```javascript
const rateLimit = require('express-rate-limit');

const adminLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});

app.use('/api/admin', adminLimiter);
```

---

## 📈 Performance Optimization

### Caching
- Redis for session storage
- Cache frequently accessed data
- Invalidate on updates

### Database
- Index important columns
- Optimize queries
- Connection pooling

### Real-time
- Socket.IO rooms for efficiency
- Throttle updates
- Batch notifications

---

## 🆘 Troubleshooting

### Admin Can't Login
```bash
# Check admin user exists
psql -d currency_exchange -c "SELECT * FROM users WHERE role='super_admin';"

# Reset admin password
psql -d currency_exchange -c "UPDATE users SET password='$2a$10$...' WHERE role='super_admin';"
```

### Real-time Not Working
```bash
# Check Socket.IO connection
# Open browser console and check for connection errors

# Verify CORS settings
# backend/src/server.js - check cors configuration
```

### Dashboard Not Loading
```bash
# Check if http-server is running
lsof -ti:8081

# Restart admin dashboard
cd admin-dashboard
http-server -p 8081
```

---

## 📚 Additional Features to Add

### Future Enhancements
- [ ] Two-factor authentication
- [ ] IP whitelisting
- [ ] Advanced fraud detection
- [ ] Automated reports
- [ ] Bulk operations
- [ ] API rate limiting per user
- [ ] Webhook integrations
- [ ] Export to Excel/PDF
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Mobile push notifications
- [ ] Scheduled tasks
- [ ] Backup & restore
- [ ] System health monitoring

---

## ✅ Summary

You now have a **powerful admin system** with:

✅ Real-time monitoring
✅ Complete control over users & transactions
✅ Instant notifications
✅ Analytics & reporting
✅ Security & audit trails
✅ Professional dashboard
✅ Mobile responsive
✅ Scalable architecture

**Start now:** `./START_ADMIN.sh`

**Access:** http://localhost:8081

**Login:** +8801700000000 / admin123

🎉 **Your admin system is ready to manage your currency exchange platform!**

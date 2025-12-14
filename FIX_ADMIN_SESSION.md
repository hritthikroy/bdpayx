# ✅ Admin Session Fixed - Complete Guide

## What Was Wrong

The admin panel was showing "Session expired" because:
1. The `adminAuth` middleware was using Supabase
2. But the actual database is local PostgreSQL
3. Token validation was failing

## What Was Fixed

✅ Updated `backend/src/middleware/adminAuth.js` to use local PostgreSQL
✅ Backend server restarted with new middleware
✅ Admin role verification now working correctly

## How to Login Now

### Option 1: Clear Session Page (Easiest)

1. Open: http://localhost:3000/clear-session.html
2. Click "Clear Session & Go to Login"
3. Login with:
   - Phone: `+8801700000000`
   - Password: `admin123`

### Option 2: Manual Clear

1. **Clear Browser Data:**
   - Press `F12` to open DevTools
   - Go to `Application` tab (Chrome) or `Storage` tab (Firefox)
   - Click `Clear storage` or `Clear site data`
   - Click the button to clear

2. **Close Tab:**
   - Close the admin panel tab completely

3. **Open Fresh:**
   - Open: http://localhost:3000
   - Login with phone: `+8801700000000`

### Option 3: Incognito/Private Window

1. Open incognito/private window
2. Go to: http://localhost:3000
3. Login with phone: `+8801700000000`

## Admin Credentials

```
Phone: +8801700000000
Password: admin123
Role: super_admin
```

⚠️ **Important:** Use PHONE number, not email!

## All URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Clear Session | http://localhost:3000/clear-session.html | Clear old session |
| Admin Login | http://localhost:3000 | Login page |
| Admin Dashboard | http://localhost:3000/index.html | Main dashboard |
| Frontend | http://localhost:8080/#/main | User app |
| Backend API | http://localhost:8081/api/ | API server |

## Troubleshooting

### Still showing "Session expired"?

1. **Check localStorage:**
   - Press F12
   - Go to Console tab
   - Type: `localStorage.clear()`
   - Press Enter
   - Refresh page

2. **Check token:**
   - Press F12
   - Go to Console tab
   - Type: `localStorage.getItem('admin_token')`
   - If it shows a token, clear it: `localStorage.removeItem('admin_token')`

3. **Check backend:**
   - Make sure backend is running on port 8081
   - Check: http://localhost:8081/api/exchange/rate
   - Should return JSON data

4. **Try different browser:**
   - If Chrome doesn't work, try Firefox
   - Or use incognito mode

## Testing the Fix

Test if the middleware is working:

```bash
# Get a fresh token
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+8801700000000","password":"admin123"}'

# Copy the token from response
# Test admin endpoint (replace YOUR_TOKEN with actual token)
curl http://localhost:8081/api/admin/v2/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"
```

If you get dashboard data (not "Invalid token"), it's working!

## All Systems Status

✅ Backend running on port 8081
✅ Admin panel running on port 3000
✅ Frontend running on port 8080
✅ Admin middleware fixed
✅ Database connection working
✅ Admin user exists with super_admin role

## Ready to Use!

1. Go to: http://localhost:3000/clear-session.html
2. Clear session
3. Login with phone: +8801700000000
4. Enjoy the admin dashboard!

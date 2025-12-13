# Admin Login Fix

## The Problem
The admin dashboard is showing errors because the authentication token is invalid or missing.

## The Solution

### Option 1: Login Through the Admin Dashboard (Recommended)

1. **Open the login page:**
   ```
   http://localhost:8080/login.html
   ```

2. **Login with admin credentials:**
   - Check `ADMIN_ACCESS.txt` for the admin credentials
   - Enter the phone number and password
   - Click Login

3. **The token will be automatically saved** and you'll be redirected to the dashboard

### Option 2: Create Admin User in Database

If you don't have an admin user yet, create one:

```bash
# Run the admin creation script
node create-admin.js
```

Or manually in Supabase:

```sql
-- Insert admin user
INSERT INTO users (phone, password, full_name, role, status, kyc_status)
VALUES (
  '+8801700000000',
  '$2b$10$...',  -- Use bcrypt to hash password
  'Admin User',
  'admin',
  'active',
  'approved'
);
```

### Option 3: Test with a Valid Token

1. **First, login through the API:**
   ```bash
   curl -X POST http://localhost:3000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"phone":"+8801700000000","password":"your_password"}'
   ```

2. **Copy the token from the response**

3. **Set it in browser console:**
   ```javascript
   localStorage.setItem('admin_token', 'YOUR_TOKEN_HERE');
   location.reload();
   ```

## What I Fixed

The admin dashboard now:
1. **Detects invalid tokens** and shows a clear error message
2. **Automatically redirects to login** when the session expires
3. **Shows toast notifications** instead of crashing
4. **Logs all API responses** for debugging

## Testing the Fix

1. **Clear your browser cache:**
   - Press Ctrl+Shift+Delete (or Cmd+Shift+Delete on Mac)
   - Clear cookies and cached files

2. **Open the admin dashboard:**
   ```
   http://localhost:8080
   ```

3. **Check the console (F12):**
   - You should see: "Dashboard data received: {error: 'Invalid token'}"
   - You should see a notification: "Session expired. Please login again."
   - You should be redirected to login page

4. **Login with valid credentials**

## Verify Backend is Running

Make sure your backend is running:

```bash
# Check if backend is running
curl http://localhost:3000/api/health

# If not running, start it:
cd backend
npm start
```

## Next Steps

1. **Clear browser cache and cookies**
2. **Go to login page:** http://localhost:8080/login.html
3. **Login with admin credentials** (check ADMIN_ACCESS.txt)
4. **Dashboard should now work**

The error "Cannot read properties of undefined (reading 'totalUsers')" will be gone because:
- Invalid tokens are now detected before trying to access data
- Error responses are handled properly
- You'll be redirected to login automatically

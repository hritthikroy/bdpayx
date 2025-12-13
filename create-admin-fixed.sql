-- Create Admin User
-- Password: admin123

-- Delete existing admin if exists
DELETE FROM users WHERE phone = '+8801700000000';

-- Create admin user
INSERT INTO users (
    phone, 
    email, 
    password_hash, 
    full_name, 
    role, 
    kyc_status, 
    balance,
    created_at
) VALUES (
    '+8801700000000',
    'admin@bdpayx.com',
    '$2a$10$GaL0rKq6wB6NAH7VziaCkemmxxXgRNUf93t.VbEGQhkrZcoPzOxRq',
    'System Admin',
    'super_admin',
    'approved',
    0,
    CURRENT_TIMESTAMP
);

-- Verify admin was created
SELECT id, phone, email, full_name, role, kyc_status 
FROM users 
WHERE phone = '+8801700000000';

-- Show success message
\echo ''
\echo '✅ Admin user created successfully!'
\echo ''
\echo 'Login Credentials:'
\echo 'Phone: +8801700000000'
\echo 'Password: admin123'
\echo ''
\echo 'Access at: http://localhost:8081/login.html'
\echo ''

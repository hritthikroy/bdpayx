-- Create Admin User
-- Password: admin123 (hashed with bcrypt)

-- First, check if role column exists, if not add it
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';

-- Delete existing admin if exists
DELETE FROM users WHERE phone = '+8801700000000';

-- Create admin user
INSERT INTO users (
    phone, 
    email, 
    password, 
    full_name, 
    role, 
    kyc_status, 
    status, 
    balance,
    created_at
) VALUES (
    '+8801700000000',
    'admin@bdpayx.com',
    '$2a$10$GaL0rKq6wB6NAH7VziaCkemmxxXgRNUf93t.VbEGQhkrZcoPzOxRq',
    'System Admin',
    'super_admin',
    'approved',
    'active',
    0,
    CURRENT_TIMESTAMP
);

-- Verify admin was created
SELECT id, phone, email, full_name, role, kyc_status, status 
FROM users 
WHERE phone = '+8801700000000';

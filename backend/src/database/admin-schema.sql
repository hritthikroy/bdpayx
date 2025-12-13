-- Admin Enhanced Schema
-- Add these tables to your existing database

-- Admin logs table
CREATE TABLE IF NOT EXISTS admin_logs (
    id SERIAL PRIMARY KEY,
    admin_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    target_id INTEGER,
    details JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admin_logs_admin ON admin_logs(admin_id);
CREATE INDEX idx_admin_logs_created ON admin_logs(created_at DESC);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- Announcements table
CREATE TABLE IF NOT EXISTS announcements (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    is_active BOOLEAN DEFAULT TRUE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE INDEX idx_announcements_active ON announcements(is_active);

-- System settings table
CREATE TABLE IF NOT EXISTS system_settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    updated_by INTEGER REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rate history table
CREATE TABLE IF NOT EXISTS rate_history (
    id SERIAL PRIMARY KEY,
    from_currency VARCHAR(10) NOT NULL,
    to_currency VARCHAR(10) NOT NULL,
    base_rate DECIMAL(10, 4) NOT NULL,
    updated_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rate_history_created ON rate_history(created_at DESC);

-- Add role column to users if not exists
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'user';
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP;

-- Add admin note to transactions
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS admin_note TEXT;

-- Add KYC review fields to users
ALTER TABLE users ADD COLUMN IF NOT EXISTS kyc_reviewed_at TIMESTAMP;
ALTER TABLE users ADD COLUMN IF NOT EXISTS kyc_reviewed_by INTEGER REFERENCES users(id);
ALTER TABLE users ADD COLUMN IF NOT EXISTS kyc_rejection_reason TEXT;

-- Create function to update user balance
CREATE OR REPLACE FUNCTION update_user_balance(p_user_id INTEGER, p_amount DECIMAL)
RETURNS VOID AS $$
BEGIN
    UPDATE users 
    SET balance = balance + p_amount,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert default system settings
INSERT INTO system_settings (key, value, description) VALUES
    ('min_exchange_amount', '100', 'Minimum BDT amount for exchange'),
    ('max_exchange_amount', '100000', 'Maximum BDT amount for exchange'),
    ('maintenance_mode', 'false', 'Enable/disable maintenance mode'),
    ('kyc_required', 'true', 'Require KYC for transactions'),
    ('auto_approve_limit', '5000', 'Auto-approve transactions below this amount')
ON CONFLICT (key) DO NOTHING;

-- Create admin user (password: admin123 - change this!)
-- Password hash for 'admin123' using bcrypt
INSERT INTO users (phone, email, password, full_name, role, kyc_status, status)
VALUES (
    '+8801700000000',
    'admin@bdpayx.com',
    '$2a$10$rOzJQjYqYqYqYqYqYqYqYuO7K7K7K7K7K7K7K7K7K7K7K7K7K7K7K',
    'System Admin',
    'super_admin',
    'approved',
    'active'
) ON CONFLICT DO NOTHING;

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE ON admin_logs TO your_db_user;
GRANT SELECT, INSERT, UPDATE ON notifications TO your_db_user;
GRANT SELECT, INSERT, UPDATE ON announcements TO your_db_user;
GRANT SELECT, INSERT, UPDATE ON system_settings TO your_db_user;
GRANT SELECT, INSERT ON rate_history TO your_db_user;

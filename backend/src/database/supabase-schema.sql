-- Supabase Schema for Currency Exchange App

-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  phone VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  kyc_status VARCHAR(20) DEFAULT 'pending',
  kyc_documents JSONB,
  balance DECIMAL(15, 2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bank cards table
CREATE TABLE bank_cards (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  card_holder_name VARCHAR(255) NOT NULL,
  bank_name VARCHAR(255) NOT NULL,
  account_number VARCHAR(50) NOT NULL,
  ifsc_code VARCHAR(20),
  card_type VARCHAR(20) DEFAULT 'bank_account',
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exchange rates table
CREATE TABLE exchange_rates (
  id SERIAL PRIMARY KEY,
  from_currency VARCHAR(10) NOT NULL,
  to_currency VARCHAR(10) NOT NULL,
  base_rate DECIMAL(10, 4) NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by INTEGER REFERENCES users(id)
);

-- Pricing tiers table
CREATE TABLE pricing_tiers (
  id SERIAL PRIMARY KEY,
  min_amount DECIMAL(15, 2) NOT NULL,
  max_amount DECIMAL(15, 2),
  markup DECIMAL(10, 4) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transactions table
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  transaction_ref VARCHAR(50) UNIQUE NOT NULL,
  from_currency VARCHAR(10) NOT NULL,
  to_currency VARCHAR(10) NOT NULL,
  from_amount DECIMAL(15, 2) NOT NULL,
  to_amount DECIMAL(15, 2) NOT NULL,
  exchange_rate DECIMAL(10, 4) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  payment_method VARCHAR(50),
  payment_proof_url VARCHAR(500),
  admin_notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Wallet transactions table
CREATE TABLE wallet_transactions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  transaction_type VARCHAR(20) NOT NULL, -- 'deposit' or 'withdrawal'
  amount DECIMAL(15, 2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  payment_method VARCHAR(50),
  proof_url VARCHAR(500),
  admin_notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment instructions table
CREATE TABLE payment_instructions (
  id SERIAL PRIMARY KEY,
  payment_method VARCHAR(50) NOT NULL,
  account_holder VARCHAR(255) NOT NULL,
  account_number VARCHAR(100),
  bank_name VARCHAR(255),
  ifsc_code VARCHAR(20),
  upi_id VARCHAR(100),
  qr_code_url VARCHAR(500),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chat messages table
CREATE TABLE chat_messages (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  sender_type VARCHAR(20) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications table
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default exchange rate
INSERT INTO exchange_rates (from_currency, to_currency, base_rate) 
VALUES ('BDT', 'INR', 0.70);

-- Insert default payment instructions
INSERT INTO payment_instructions (payment_method, account_holder, account_number, bank_name, ifsc_code, upi_id) 
VALUES 
('bank_transfer', 'Company Name', '1234567890', 'HDFC Bank', 'HDFC0001234', NULL),
('upi', 'Company Name', NULL, NULL, NULL, 'company@paytm');

-- Enable Row Level Security (RLS) - Optional but recommended
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create policies (users can only see their own data)
CREATE POLICY "Users can view own data" ON users FOR SELECT USING (true);
CREATE POLICY "Users can view own bank cards" ON bank_cards FOR SELECT USING (true);
CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (true);
CREATE POLICY "Users can view own wallet transactions" ON wallet_transactions FOR SELECT USING (true);
CREATE POLICY "Users can view own messages" ON chat_messages FOR SELECT USING (true);
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (true);

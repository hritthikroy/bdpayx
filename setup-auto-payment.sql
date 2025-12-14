-- Add transaction_id column to wallet_deposits if not exists
ALTER TABLE wallet_deposits 
ADD COLUMN IF NOT EXISTS transaction_id VARCHAR(255) UNIQUE;

-- Create unmatched payments table
CREATE TABLE IF NOT EXISTS unmatched_payments (
  id SERIAL PRIMARY KEY,
  method VARCHAR(50) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  sender VARCHAR(20),
  trx_id VARCHAR(255) UNIQUE,
  sms_body TEXT,
  sms_timestamp TIMESTAMP,
  matched BOOLEAN DEFAULT FALSE,
  matched_deposit_id INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_wallet_deposits_transaction_id 
ON wallet_deposits(transaction_id);

CREATE INDEX IF NOT EXISTS idx_wallet_deposits_pending 
ON wallet_deposits(status, payment_method, created_at) 
WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS idx_unmatched_payments_trx_id 
ON unmatched_payments(trx_id);

CREATE INDEX IF NOT EXISTS idx_unmatched_payments_matched 
ON unmatched_payments(matched, created_at) 
WHERE matched = false;

-- Add comment
COMMENT ON TABLE unmatched_payments IS 'Stores SMS payments that could not be automatically matched to pending deposits';

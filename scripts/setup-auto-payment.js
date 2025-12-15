const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Load environment variables
require('dotenv').config({ path: path.join(__dirname, 'backend', '.env') });

// Create pool directly
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

async function setupAutoPayment() {
  const client = await pool.connect();
  
  try {
    console.log('Setting up automatic payment verification system...\n');

    // Read SQL file
    const sql = fs.readFileSync('./setup-auto-payment.sql', 'utf8');

    // Execute SQL
    await client.query(sql);

    console.log('✓ Database tables created');
    console.log('✓ Indexes created');
    console.log('✓ transaction_id column added to wallet_deposits');
    console.log('✓ unmatched_payments table created\n');

    // Check if SMS_WEBHOOK_KEY is set
    if (!process.env.SMS_WEBHOOK_KEY || process.env.SMS_WEBHOOK_KEY === 'change-this-secret-key') {
      console.log('⚠ WARNING: Please set SMS_WEBHOOK_KEY in your .env file');
      console.log('Add this line to .env:');
      console.log('SMS_WEBHOOK_KEY=' + generateRandomKey());
      console.log('');
    } else {
      console.log('✓ SMS_WEBHOOK_KEY is configured\n');
    }

    console.log('Setup complete! Next steps:');
    console.log('1. Build the Android app from android-sms-monitor/ folder');
    console.log('2. Install app on Android device');
    console.log('3. Configure server URL and API key in the app');
    console.log('4. Grant SMS permissions');
    console.log('5. Test with a small deposit\n');

  } catch (error) {
    console.error('Setup failed:', error.message);
    process.exit(1);
  } finally {
    client.release();
    process.exit(0);
  }
}

function generateRandomKey() {
  return require('crypto').randomBytes(32).toString('hex');
}

setupAutoPayment();

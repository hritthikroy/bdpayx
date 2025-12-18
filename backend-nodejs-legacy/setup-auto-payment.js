require('dotenv').config();
const pool = require('./src/config/database');
const fs = require('fs');
const path = require('path');

async function setupAutoPayment() {
  const client = await pool.connect();
  
  try {
    console.log('Setting up automatic payment verification system...\n');

    // Read SQL file
    const sqlPath = path.join(__dirname, '..', 'setup-auto-payment.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    // Execute SQL
    await client.query(sql);

    console.log('✓ Database tables created');
    console.log('✓ Indexes created');
    console.log('✓ transaction_id column added to wallet_deposits');
    console.log('✓ unmatched_payments table created\n');

    // Check if SMS_WEBHOOK_KEY is set
    if (!process.env.SMS_WEBHOOK_KEY || process.env.SMS_WEBHOOK_KEY === 'change-this-secret-key') {
      const newKey = generateRandomKey();
      console.log('⚠ WARNING: SMS_WEBHOOK_KEY not configured');
      console.log('Add this line to backend/.env:');
      console.log(`SMS_WEBHOOK_KEY=${newKey}`);
      console.log('');
      
      // Append to .env file
      const envPath = path.join(__dirname, '.env');
      fs.appendFileSync(envPath, `\n# SMS Webhook for Auto Payment\nSMS_WEBHOOK_KEY=${newKey}\n`);
      console.log('✓ SMS_WEBHOOK_KEY added to .env file\n');
    } else {
      console.log('✓ SMS_WEBHOOK_KEY is configured\n');
    }

    console.log('Setup complete! Next steps:');
    console.log('1. Build the Android app from android-sms-monitor/ folder');
    console.log('2. Install app on Android device');
    console.log('3. Configure server URL and API key in the app');
    console.log('4. Grant SMS permissions');
    console.log('5. Test with a small deposit\n');
    
    console.log('📱 Android App Configuration:');
    console.log(`   Server URL: ${process.env.APP_URL || 'https://yourdomain.com'}`);
    console.log(`   API Key: ${process.env.SMS_WEBHOOK_KEY || newKey}`);
    console.log('');

  } catch (error) {
    console.error('Setup failed:', error.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
    process.exit(0);
  }
}

function generateRandomKey() {
  return require('crypto').randomBytes(32).toString('hex');
}

setupAutoPayment();

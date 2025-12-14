// Create Admin User Script
require('dotenv').config();
const pool = require('./src/config/database');
const bcrypt = require('bcryptjs');

async function createAdmin() {
  try {
    const hashedPassword = await bcrypt.hash('admin123', 10);
    
    // Check if admin exists
    const checkResult = await pool.query(
      "SELECT * FROM users WHERE email = 'admin@bdpayx.com'"
    );

    if (checkResult.rows.length > 0) {
      console.log('✅ Admin user already exists!');
      console.log('');
      console.log('Admin Credentials:');
      console.log('Email: admin@bdpayx.com');
      console.log('Password: admin123');
      console.log('');
      console.log('Login at: http://localhost:3000');
    } else {
      console.log('Creating new admin user...');
      
      // Create new admin
      await pool.query(
        `INSERT INTO users (phone, email, password_hash, full_name, kyc_status, balance)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          '+8801700000000',
          'admin@bdpayx.com',
          hashedPassword,
          'System Admin',
          'approved',
          0
        ]
      );
      
      console.log('✅ Admin user created successfully!');
      console.log('');
      console.log('Admin Credentials:');
      console.log('Email: admin@bdpayx.com');
      console.log('Password: admin123');
      console.log('');
      console.log('Login at: http://localhost:3000');
    }
    
    await pool.end();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin:', error.message);
    process.exit(1);
  }
}

createAdmin();

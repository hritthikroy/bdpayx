// Create Admin User Script
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'currency_exchange',
  user: process.env.DB_USER || 'hritthik',
  password: process.env.DB_PASSWORD || ''
});

async function createAdmin() {
  try {
    const hashedPassword = await bcrypt.hash('admin123', 10);
    
    // Check if admin exists
    const checkResult = await pool.query(
      "SELECT * FROM users WHERE phone = '+8801700000000'"
    );

    if (checkResult.rows.length > 0) {
      console.log('Admin user already exists. Updating...');
      
      // Update existing user
      await pool.query(
        `UPDATE users 
         SET password = $1, role = 'super_admin', kyc_status = 'approved', status = 'active'
         WHERE phone = '+8801700000000'`,
        [hashedPassword]
      );
      
      console.log('✅ Admin user updated successfully!');
    } else {
      console.log('Creating new admin user...');
      
      // Create new admin
      await pool.query(
        `INSERT INTO users (phone, email, password, full_name, role, kyc_status, status, balance)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [
          '+8801700000000',
          'admin@bdpayx.com',
          hashedPassword,
          'System Admin',
          'super_admin',
          'approved',
          'active',
          0
        ]
      );
      
      console.log('✅ Admin user created successfully!');
    }

    console.log('');
    console.log('Admin Credentials:');
    console.log('Phone: +8801700000000');
    console.log('Password: admin123');
    console.log('');
    console.log('Login at: http://localhost:8081/login.html');
    
    await pool.end();
    process.exit(0);
  } catch (error) {
    console.error('Error creating admin:', error);
    process.exit(1);
  }
}

createAdmin();

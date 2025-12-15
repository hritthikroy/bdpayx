require('dotenv').config({ path: './backend/.env' });
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

async function setupSupportTables() {
  console.log('🔧 Setting up support tables in Supabase...');
  
  try {
    // Read the SQL schema
    const sql = fs.readFileSync('./backend/src/database/support-schema.sql', 'utf8');
    
    console.log('📝 SQL Schema:');
    console.log(sql);
    console.log('\n⚠️  Please run this SQL manually in your Supabase SQL Editor:');
    console.log('1. Go to https://supabase.com/dashboard/project/cvsdypdlpngytpshivgw/sql/new');
    console.log('2. Copy the SQL above');
    console.log('3. Paste and run it in the SQL editor');
    console.log('\nOr use the Supabase CLI:');
    console.log('supabase db push --db-url "postgresql://postgres:[YOUR-PASSWORD]@db.cvsdypdlpngytpshivgw.supabase.co:5432/postgres"');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

setupSupportTables();

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL || 'https://cvsdypdlpngytpshivgw.supabase.co';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2c2R5cGRscG5neXRwc2hpdmd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1NzAxMzAsImV4cCI6MjA4MTE0NjEzMH0.RD_LzkarkVTXxcdbX2H_ofa8uOiILVDrQQn8JBAL65I';

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = { supabase };

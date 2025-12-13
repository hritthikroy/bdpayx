import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cvsdypdlpngytpshivgw.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2c2R5cGRscG5neXRwc2hpdmd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1NzAxMzAsImV4cCI6MjA4MTE0NjEzMH0.RD_LzkarkVTXxcdbX2H_ofa8uOiILVDrQQn8JBAL65I',
  );
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}

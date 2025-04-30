// lib/database.dart
import 'package:supabase_flutter/supabase_flutter.dart';
class Database {
  static const _url = 'https://txpmsjheryxladcdbiko.supabase.co';
  static const _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4cG1zamhlcnl4bGFkY2RiaWtvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzNzYxNzUsImV4cCI6MjA1Nzk1MjE3NX0.dqmOim72aohR4mW3eHKuWQxHC_w2JTGLDIpM4C9okwk';

  /// Gọi hàm này trước runApp()
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: _url,
        anonKey: _anonKey,
      );
      print("Suppabase init complete succesfully");
    }
    catch(e,stackTree){
      print('Failed to initialize Supabase:$e');
      print(stackTree);
    }
  }

  /// Lấy client để dùng truy vấn
  static SupabaseClient get client => Supabase.instance.client;
  static Future<void> fetchFruits() async {
    try {
      final response = await client.from('Fruit').select('*');
      print('🍓 List of fruits:');
      for (var fruit in response) {
        print(fruit);
      }
    } catch (e) {
      print('❌ Error fetching fruits: $e');
    }
  }
}

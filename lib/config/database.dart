// lib/database.dart
import 'package:supabase_flutter/supabase_flutter.dart';
class Database {
  static const _url = 'https://xfxmyhnkchzoyzzpjctl.supabase.co';
  static const _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhmeG15aG5rY2h6b3l6enBqY3RsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwODc5OTcsImV4cCI6MjA2MTY2Mzk5N30.XZipF1i2Y1BZkWQu0dxuDK6kFQfWdkZMXGk6nVWJMzM';

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
      final response = await client.from('account').select('*');
      print('🍓 List of account:');
      for (var account in response) {
        print(account);
      }
    } catch (e) {
      print('❌ Error fetching fruits: $e');
    }
  }
}

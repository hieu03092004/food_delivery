import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../model/shipper_model/Notification_model.dart';

class NotificationService {
  final _base = 'http://10.0.2.2:3000/notifications';
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<List<NotificationItem>> getAllNotifications(int accountId) async {
    final response = await _supabase
        .from('notification')
        .select()
        .eq('recipient_id', accountId)
        .order('created_at', ascending: false);

    print(response);
    final raw = response as List<dynamic>;
    print('Data":$raw');
    return raw
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  Future<List<NotificationItem>> getNotificationsByDateRange(
      int accountId, DateTime start, DateTime end) async {
    final response = await _supabase
        .from('notification')
        .select()
        .eq('recipient_id', accountId)
        .gte('created_at', start.toIso8601String())
        .lt('created_at', end.toIso8601String())
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;

    return data
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lấy thông báo “Hôm nay” theo giờ server
  Future<List<NotificationItem>> getTodayNotifications(int accountId) {
    print("Vao today");
    final now = DateTime.now();
    final startOfDay =
    DateTime(now.year, now.month, now.day); // 00:00:00 hôm nay
    final startOfTomorrow =
    startOfDay.add(const Duration(days: 1)); // 00:00:00 ngày mai
    return getNotificationsByDateRange(accountId, startOfDay, startOfTomorrow);
  }

  /// Lấy thông báo “Hôm qua”
  Future<List<NotificationItem>> getYesterdayNotifications(int accountId) {
    print("Vao yesterday");
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfToday.subtract(const Duration(days: 1));
    return getNotificationsByDateRange(
        accountId, startOfYesterday, startOfToday);
  }

}
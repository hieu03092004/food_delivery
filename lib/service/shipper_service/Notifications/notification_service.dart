import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../model/shipper_model/Notification_model.dart';

class NotificationService extends GetxController {
  final String apiUrl =
      'https://flutter-notifications.vercel.app/notifications';
  final int userId;

  // Observable state
  final RxInt unreadCount = 0.obs;
  bool unreadCountLoaded = false;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;

  NotificationService(this.userId);

  // Fetch unread notification count
  Future<void> fetchUnreadCount() async {
    try {
      final res = await http.get(
        Uri.parse('$apiUrl/unread_count?recipient_id=$userId'),
      );
      if (res.statusCode == 200) {
        unreadCount.value = json.decode(res.body)['unread_count'];
      }
    } catch (e) {
      // Error handling
    }
  }

  // Fetch notifications by filter
  Future<void> fetchByFilter(String filter) async {
    try {
      isLoading.value = true;

      final res = await http.get(
        Uri.parse('$apiUrl?recipient_id=$userId&filter=$filter'),
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(res.body);
        final list = jsonList.map((j) => NotificationItem.fromJson(j)).toList();
        notifications.value = list;

        // Update unread count
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      // Error handling
    } finally {
      isLoading.value = false;
    }
  }

  // Mark notifications as read by filter
  Future<void> markReadByFilter(String filter) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/mark_read_by_filter'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'recipient_id': userId, 'filter': filter}),
      );

      if (res.statusCode != 200) {
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      for (var n in notifications) {
        final created = n.createdAt;
        final shouldMark = switch (filter) {
          'all' => true,
          'today' => created.isAfter(today),
          'yesterday' => created.isAfter(yesterday) && created.isBefore(today),
          _ => false,
        };

        if (shouldMark) {
          final index = notifications.indexOf(n);
          notifications[index] = n.copyWith(isRead: true);
        }
      }

      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (e) {
      // Error handling
    }
  }

  // Initialize notifications for today
  Future<void> initializeTodayNotifications() async {
    await markReadByFilter('today');
    await fetchByFilter('today');
    await fetchUnreadCount();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
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

  NotificationService(this.userId) {
    debugPrint('NotificationService initialized with userId: $userId');
  }

  // Fetch unread notification count
  Future<void> fetchUnreadCount() async {
    try {
      debugPrint('Fetching unread count for userId: $userId');
      final res = await http.get(
        Uri.parse('$apiUrl/unread_count?recipient_id=$userId'),
      );
      debugPrint('Response: ${res.body}');
      if (res.statusCode == 200) {
        unreadCount.value = json.decode(res.body)['unread_count'];
        debugPrint('Unread count: ${unreadCount.value}');
      } else {
        debugPrint('Error fetching unread count: ${res.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching unread count: $e');
    }
  }

  // Fetch notifications by filter
  Future<void> fetchByFilter(String filter) async {
    try {
      isLoading.value = true;
      debugPrint('Fetching notifications for filter: $filter, userId: $userId');

      final res = await http.get(
        Uri.parse('$apiUrl?recipient_id=$userId&filter=$filter'),
      );

      debugPrint('Response status: ${res.statusCode}');
      debugPrint('Response body: ${res.body}');

      if (res.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(res.body);
        debugPrint('Number of notifications received: ${jsonList.length}');

        final list = jsonList.map((j) => NotificationItem.fromJson(j)).toList();
        notifications.value = list;

        // Update unread count
        unreadCount.value = notifications.where((n) => !n.isRead).length;
        debugPrint(
          'Updated notifications list length: ${notifications.length}',
        );
      } else {
        debugPrint('Error fetching notifications: ${res.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mark notifications as read by filter
  Future<void> markReadByFilter(String filter) async {
    try {
      debugPrint(
        'Marking notifications as read for filter: $filter, userId: $userId',
      );
      final res = await http.post(
        Uri.parse('$apiUrl/mark_read_by_filter'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'recipient_id': userId, 'filter': filter}),
      );

      debugPrint('Mark read response: ${res.body}');

      if (res.statusCode != 200) {
        debugPrint('Error marking as read: ${res.body}');
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
      debugPrint(
        'Updated unread count after marking as read: ${unreadCount.value}',
      );
    } catch (e) {
      debugPrint('Exception marking notifications as read: $e');
    }
  }

  // Initialize notifications for today
  Future<void> initializeTodayNotifications() async {
    debugPrint('Initializing today notifications for userId: $userId');
    await markReadByFilter('today');
    await fetchByFilter('today');
    await fetchUnreadCount();
  }
}

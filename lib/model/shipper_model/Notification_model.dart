import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationItem {
  final int id;
  final int? orderId;
  final String message;
  final String ?title;
    bool isRead;
  final DateTime createdAt;

  /// Danh sách product_id có trong đơn hàng này
  final List<int> productIds;

  NotificationItem({
    required this.id,
    this.orderId,
    required this.message,
    this.title,
    required this.isRead,
    required this.createdAt,
    required this.productIds,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    // Supabase sẽ trả về nested map theo key "orders" → "order_items"
    final orderItems = (json['orders']?['order_items'] as List<dynamic>?)
        ?.map((e) => (e as Map<String, dynamic>)['product_id'] as int)
        .toList() ??
        <int>[];
    return NotificationItem(
      id: json['notification_id'] as int,
      orderId: json['order_id'] as int?,
      message: json['message'] as String,
      title: json['title'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      productIds: orderItems,
    );
  }
}
class NotificationProvider extends ChangeNotifier {
  final String apiUrl = 'https://flutter-notifications.vercel.app/notifications';
  final int userId;
  NotificationProvider(this.userId);

  int unreadCount = 0;
  List<NotificationItem> notifications = [];

  Future<void> fetchUnreadCount() async {
    final res = await http.get(
        Uri.parse('$apiUrl/unread_count?recipient_id=$userId')
    );
    print("fectchUnreadCount");
    unreadCount = json.decode(res.body)['unread_count'];
    notifyListeners();
  }

  Future<void> fetchByFilter(String filter) async {
    print('fetchByFilter:$filter');
    final res = await http.get(
        Uri.parse('$apiUrl?recipient_id=$userId&filter=$filter')
    );
    print('Status code: ${res.statusCode}');
    print('Body: ${res.body}');
    final list = (json.decode(res.body) as List)
        .map((j) => NotificationItem.fromJson(j))
        .toList();
    notifications = list;
    // cập nhật lại count
    unreadCount = notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  Future<void> markReadByFilter(String filter) async {
    print('markReadByFilter:$filter');
    final res = await http.post(
      Uri.parse('$apiUrl/mark_read_by_filter'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'recipient_id': userId,
        'filter': filter,
      }),
    );

    //print('Res:$res');

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

      if (shouldMark) n.isRead = true;
    }

    unreadCount = notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

}


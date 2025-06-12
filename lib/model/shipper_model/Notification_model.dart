class NotificationItem {
  final int id;
  final int? orderId;
  final String message;
  final String? title;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    this.orderId,
    required this.message,
    this.title,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['notification_id'] as int,
      orderId: json['order_id'] as int?,
      message: json['message'] as String,
      title: json['title'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': id,
      'order_id': orderId,
      'message': message,
      'title': title,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationItem copyWith({
    int? id,
    int? orderId,
    String? message,
    String? title,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      message: message ?? this.message,
      title: title ?? this.title,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

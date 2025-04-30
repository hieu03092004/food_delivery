class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final String? orderCode;
  final String? iconUrl; // icon mặc định nếu null

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    this.orderCode,
    this.iconUrl,
  });
}

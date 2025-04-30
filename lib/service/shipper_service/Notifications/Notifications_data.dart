import '../../../model/shipper_model/Notification_model.dart';

final List<NotificationItem> notifications = [
  NotificationItem(
    id: 'n1',
    title: 'Đơn hàng đã hoàn tất',
    orderCode: '2504135FM7X01Y',
    message: 'đã hoàn thành. Bạn hãy đánh giá sản phẩm trước ngày 19-05-2025 để nhận 300 xu và giúp người dùng khác hiểu hơn về sản phẩm nhé!',
    dateTime: DateTime(2025, 4, 26, 10, 55),
    iconUrl: null,
  ),
  NotificationItem(
    id: 'n2',
    title: 'Đơn hàng đã hoàn tất',
    orderCode: '2504135ZH7PW5X',
    message: 'đã hoàn thành. Bạn hãy đánh giá sản phẩm trước ngày 19-05-2025 để nhận 300 xu và giúp người dùng khác hiểu hơn về sản phẩm nhé!',
    dateTime: DateTime(2025, 4, 26, 10, 55),
    iconUrl: null,
  ),
  NotificationItem(
    id: 'n3',
    title: 'Nhắc nhở: Bạn đã nhận được hàng chưa?',
    orderCode: '2504135E5WHXU',
    message: 'Nếu bạn chưa nhận được hàng hoặc gặp vấn đề về đơn hàng này, hãy nhấn Trả hàng/Hoàn tiền trước ngày 19-04-2025. Sau thời gian này, Shopee sẽ hoàn thành giao dịch cho Người bán.',
    dateTime: DateTime(2025, 4, 27, 9, 30),
    iconUrl: null,
  ),
];
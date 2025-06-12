import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../model/shipper_model/order_model.dart';
import '../../../service/auth_servicae/AuthService.dart';

class OrderService extends GetxController {
  final Map<String, List<OrderWithItems>> _ordersByStatus = {};
  final RxBool isLoading = false.obs;
  final List<String> tabs = [
    'Đã nhận đơn',
    'Đang vận chuyển',
    'Đã giao',
    'Giao thất bại',
    'Đã huỷ',
  ];
  final Map<String, String> _uiToDbStatusMap = {
    'Đã nhận đơn': 'order_received',
    'Đang vận chuyển': 'in_transit',
    'Đã giao': 'delivered',
    'Giao thất bại': 'delivered_failed',
    'Đã huỷ': 'canceled',
  };

  final Map<String, String> _dbToUiStatusMap = {
    'order_received': 'Đã nhận đơn',
    'in_transit': 'Đang vận chuyển',
    'delivered': 'Đã giao',
    'delivered_failed': 'Giao thất bại',
    'canceled': 'Đã huỷ',
  };
  final Map<String, String> _nextStatusMap = {
    'order_received': 'in_transit',
    'in_transit': 'delivered',
  };

  @override
  void onInit() {
    super.onInit();
    for (var status in tabs) {
      loadOrdersFor(status);
    }
  }

  List<OrderWithItems> getOrdersByStatus(String status) {
    if (_ordersByStatus[status] == null) {
      loadOrdersFor(status);
    }
    return _ordersByStatus[status] ?? [];
  }

  Map<String, String> get dbToUiStatusMap => _dbToUiStatusMap;
  Map<String, String> get nextStatusMap => _nextStatusMap;

  Future<void> loadOrdersFor(String uiStatus) async {
    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final userId = authService.accountId.value;

      if (userId == 0) {
        throw Exception('User chưa login');
      }

      final dbStatus = _uiToDbStatusMap[uiStatus];
      if (dbStatus == null) {
        return;
      }

      final list = await OrderSnapshot.getOrdersByStatus(dbStatus, userId);
      _ordersByStatus[uiStatus] = list;
      update();
    } catch (e) {
      // Error handling
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> processNextStatus(OrderWithItems order) async {
    try {
      final result = await processOrderStatusUpdate(order);
      if (result.success && result.newStatus != null) {
        final oldStatus = _dbToUiStatusMap[order.status];
        if (oldStatus != null) {
          await loadOrdersFor(oldStatus);
        }
        await loadOrdersFor(result.newStatus!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> processDeliveredFailed(OrderWithItems order) async {
    try {
      final result = await processOrderDeliveredFailed(order);
      if (result.success && result.newStatus != null) {
        final oldStatus = _dbToUiStatusMap[order.status];
        if (oldStatus != null) {
          await loadOrdersFor(oldStatus);
        }
        await loadOrdersFor(result.newStatus!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<UpdateOrderResult> processOrderStatusUpdate(
    OrderWithItems order,
  ) async {
    final currentDb = order.status;
    final nextDb = _nextStatusMap[currentDb];

    if (nextDb == null) {
      return UpdateOrderResult(
        success: false,
        message: 'Không có trạng thái tiếp theo',
      );
    }

    final oldUi = _dbToUiStatusMap[currentDb]!;
    final newUi = _dbToUiStatusMap[nextDb]!;

    try {
      final updateSuccess = await OrderSnapshot.updateOrderStatus(
        order.id,
        nextDb,
      );
      if (!updateSuccess) {
        return UpdateOrderResult(
          success: false,
          message: 'Lỗi khi cập nhật trạng thái đơn hàng',
        );
      }

      String content = '';
      String titleNotifications = '';

      if (newUi == 'Đã giao') {
        content = 'Đơn hàng ${order.id} của bạn đã được giao thành công';
        titleNotifications = 'Giao kiện hàng thành công';
      } else {
        content =
            'Đơn hàng ${order.id} của bạn đang trong quá trình vận chuyển';
        titleNotifications = 'Đang vận chuyển';
      }

      final deviceToken = await OrderSnapshot.getCustomerDeviceToken(
        order.customerId,
      );

      await OrderSnapshot.createNotification(
        recipientId: order.customerId,
        orderId: order.id,
        message: content,
        title: titleNotifications,
      );

      await sendFCMNotification(
        deviceToken: deviceToken,
        title: 'Cập nhật đơn hàng',
        body: content,
      );

      return UpdateOrderResult(
        success: true,
        message: 'Cập nhật thành công',
        oldStatus: oldUi,
        newStatus: newUi,
        newDbStatus: nextDb,
      );
    } catch (e) {
      return UpdateOrderResult(success: false, message: 'Lỗi: $e');
    }
  }

  Future<UpdateOrderResult> processOrderDeliveredFailed(
    OrderWithItems order,
  ) async {
    const String nextDb = 'delivered_failed';
    const String newUi = 'Giao thất bại';
    final String oldDb = order.status;
    final String oldUi = _dbToUiStatusMap[oldDb]!;

    try {
      final updateSuccess = await OrderSnapshot.updateOrderStatus(
        order.id,
        nextDb,
      );
      if (!updateSuccess) {
        return UpdateOrderResult(
          success: false,
          message: 'Lỗi khi cập nhật trạng thái đơn hàng',
        );
      }

      final String content = 'Đơn hàng ${order.id} của bạn đã giao thất bại';
      const String notificationTitle = 'Giao thất bại';

      final deviceToken = await OrderSnapshot.getCustomerDeviceToken(
        order.customerId,
      );

      await OrderSnapshot.createNotification(
        recipientId: order.customerId,
        orderId: order.id,
        message: content,
        title: notificationTitle,
      );

      await sendFCMNotification(
        deviceToken: deviceToken,
        title: 'Cập nhật đơn hàng',
        body: content,
      );

      return UpdateOrderResult(
        success: true,
        message: 'Cập nhật thành công',
        oldStatus: oldUi,
        newStatus: newUi,
        newDbStatus: nextDb,
      );
    } catch (e) {
      return UpdateOrderResult(success: false, message: 'Lỗi: $e');
    }
  }

  Future<bool> sendFCMNotification({
    required String? deviceToken,
    required String title,
    required String body,
  }) async {
    if (deviceToken == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://flutter-notifications.vercel.app/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceToken': deviceToken,
          'title': title,
          'body': body,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (httpError) {
      return false;
    }
  }
}

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderService>(() => OrderService());
  }
}

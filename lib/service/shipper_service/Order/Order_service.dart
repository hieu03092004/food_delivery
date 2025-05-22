import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../model/shipper_model/order_model.dart';

class OrderService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final Map<String, String> _uiToDbStatusMap = {
    'Đã nhận đơn': 'order_received',
    'Đang vận chuyển': 'in_transit',
    'Đã giao': 'delivered',
    'Giao thất bại': 'delivered_failed',
    'Đã huỷ': 'canceled',
  };

  // Map ngược lại từ giá trị database sang UI
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
  Future<List<OrderWithItems>> getOrdersByUiStatus(String uiStatus,int UserId) async {
    // Chuyển đổi từ nhãn UI tiếng Việt sang giá trị tiếng Anh trong DB
    final dbStatus = _uiToDbStatusMap[uiStatus];

    if (dbStatus == null) {
      print('⚠️ Invalid UI status: $uiStatus');
      return [];
    }

    return await getOrdersByDbStatus(dbStatus,UserId);
  }
  // Lấy đơn hàng theo trạng thái
  Future<List<OrderWithItems>> getOrdersByDbStatus(String dbStatus,int userID) async {
    print("Status:${dbStatus}");
    try {
      print("🔍 Fetching orders with status: $dbStatus for userId: $userID");
      final raw = await _supabaseClient
          .rpc('get_orders_by_status', params: {'order_status': dbStatus, 'p_shipper_id': userID, });
      print('raw pc result for status ${dbStatus}:$raw');
      if(raw is!List){
        print('⚠️ Unexpected RPC result, not a List: $raw');
        return [];
      }
      final List<dynamic>data=raw;


      // 1) Parse List<dynamic> -> List<Order>
      final flatOrders = (raw as List<dynamic>).map((json) {
        final o = Order.fromJson(json as Map<String, dynamic>);
        o.statusText = _dbToUiStatusMap[o.status] ?? o.status;
        o.totalAmount = o.discountedPrice * o.quantity + o.shippingFee;
        return o;
      }).toList();

      // 2) Nhóm theo order.id
      final Map<int, List<Order>> buffer = {};
      for (var o in flatOrders) {
        buffer.putIfAbsent(o.id, () => []).add(o);
      }

      // 3) Build List<OrderWithItems> từ map
      final grouped = buffer.entries.map((e) {
        final items = e.value;
        final first = items.first;
        return OrderWithItems(
          id: first.id,
          customerId: first.customerId,
          customerName: first.customerName,
          storeName: first.storeName,
          status: first.status,
          statusText: first.statusText,
          shippingFee: first.shippingFee,
          orderDate: first.orderDate,
          items: items,
        );
      }).toList();

      return grouped;
    } catch (e) {
      print('Error fetching orders by status: $e');
      return [];
    }
  }
  // Cập nhật trạng thái đơn hàng tiếp theo
  Future<bool> updateOrderStatusToNext(OrderWithItems order) async {
    try {
      final currentDb = order.status;
      final nextDb = _nextStatusMap[currentDb];

      if (nextDb == null) {
        print('⚠️ Không có trạng thái tiếp theo cho: $currentDb');
        return false;
      }

      await _supabaseClient
          .from('orders')
          .update({'status': nextDb})
          .eq('order_id', order.id);

      return true;
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái đơn hàng: $e');
      return false;
    }
  }
  // Cập nhật trạng thái đơn hàng thành "Giao thất bại"
  Future<bool> updateOrderStatusToDeliveredFailed(int orderId) async {
    try {
      await _supabaseClient
          .from('orders')
          .update({'status': 'delivered_failed'})
          .eq('order_id', orderId);

      return true;
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái thành giao thất bại: $e');
      return false;
    }
  }
  // Lấy device token của khách hàng
  Future<String?> getCustomerDeviceToken(int customerId) async {
    try {
      final tokenRes = await _supabaseClient
          .from('account')
          .select('tokendevice')
          .eq('account_id', customerId)
          .single();

      final String? deviceToken = tokenRes['tokendevice'] as String?;

      if (deviceToken == null) {
        print('⚠️ User $customerId chưa có deviceToken');
      } else {
        print('👉 Device token: $deviceToken');
      }

      return deviceToken;
    } catch (e) {
      print('❌ Lỗi khi lấy device token: $e');
      return null;
    }
  }
  // Tạo notification trong database
  Future<bool> createNotification({
    required int recipientId,
    required int orderId,
    required String message,
    required String title,
  }) async {
    try {
      await _supabaseClient.from('notification').insert({
        'recipient_id': recipientId,
        'order_id': orderId,
        'message': message,
        'title': title,
      });

      return true;
    } catch (e) {
      print('❌ Lỗi khi tạo notification: $e');
      return false;
    }
  }
  // Gửi FCM notification
  Future<bool> sendFCMNotification({
    required String? deviceToken,
    required String title,
    required String body,
  }) async {
    if (deviceToken == null) {
      print('⚠️ Device token null, không thể gửi FCM');
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
        print('📦 Gửi FCM thành công: ${response.body}');
        try {
          final responseData = jsonDecode(response.body);
          print('📦 Chi tiết phản hồi: $responseData');
        } catch (jsonError) {
          print('⚠️ Lỗi phân tích JSON phản hồi: $jsonError');
        }
        return true;
      } else {
        print('⚠️ Gửi FCM thất bại: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (httpError) {
      print('❌ Lỗi kết nối khi gửi FCM: $httpError');
      return false;
    }
  }
  // Xử lý cập nhật trạng thái và gửi thông báo (cho trạng thái tiếp theo)
  Future<UpdateOrderResult> processOrderStatusUpdate(OrderWithItems order) async {
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
      // 1. Cập nhật status trong database
      final updateSuccess = await updateOrderStatusToNext(order);
      if (!updateSuccess) {
        return UpdateOrderResult(
          success: false,
          message: 'Lỗi khi cập nhật trạng thái đơn hàng',
        );
      }

      // 2. Tạo nội dung thông báo
      String content = '';
      String titleNotifications = '';

      if (newUi == 'Đã giao') {
        content = 'Đơn hàng ${order.id} của bạn đã được giao thành công';
        titleNotifications = 'Giao kiện hàng thành công';
      } else {
        content = 'Đơn hàng ${order.id} của bạn đang trong quá trình vận chuyển';
        titleNotifications = 'Đang vận chuyển';
      }

      // 3. Lấy device token
      final deviceToken = await getCustomerDeviceToken(order.customerId);

      // 4. Tạo notification trong database
      await createNotification(
        recipientId: order.customerId,
        orderId: order.id,
        message: content,
        title: titleNotifications,
      );

      // 5. Gửi FCM
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
      print('❌ Lỗi khi xử lý cập nhật trạng thái: $e');
      return UpdateOrderResult(
        success: false,
        message: 'Lỗi: $e',
      );
    }
  }
  // Xử lý cập nhật trạng thái thành "Giao thất bại"
  Future<UpdateOrderResult> processOrderDeliveredFailed(OrderWithItems order) async {
    const String nextDb = 'delivered_failed';
    const String newUi = 'Giao thất bại';
    final String oldDb = order.status;
    final String oldUi = _dbToUiStatusMap[oldDb]!;

    try {
      // 1. Cập nhật status trong database
      final updateSuccess = await updateOrderStatusToDeliveredFailed(order.id);
      if (!updateSuccess) {
        return UpdateOrderResult(
          success: false,
          message: 'Lỗi khi cập nhật trạng thái đơn hàng',
        );
      }

      // 2. Tạo nội dung thông báo
      final String content = 'Đơn hàng ${order.id} của bạn đã giao thất bại';
      const String notificationTitle = 'Giao thất bại';

      // 3. Lấy device token
      final deviceToken = await getCustomerDeviceToken(order.customerId);

      // 4. Tạo notification trong database
      await createNotification(
        recipientId: order.customerId,
        orderId: order.id,
        message: content,
        title: notificationTitle,
      );

      // 5. Gửi FCM
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
      print('❌ Lỗi khi xử lý giao thất bại: $e');
      return UpdateOrderResult(
        success: false,
        message: 'Lỗi: $e',
      );
    }
  }

  // Lấy map status để sử dụng trong UI
  Map<String, String> get dbToUiStatusMap => _dbToUiStatusMap;
  Map<String, String> get nextStatusMap => _nextStatusMap;



}
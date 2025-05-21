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
  Future<List<OrderWithItems>> getOrdersByUiStatus(String uiStatus,int UserId) async {
    // Chuyển đổi từ nhãn UI tiếng Việt sang giá trị tiếng Anh trong DB
    final dbStatus = _uiToDbStatusMap[uiStatus];

    if (dbStatus == null) {
      print('⚠️ Invalid UI status: $uiStatus');
      return [];
    }

    return await getOrdersByDbStatus(dbStatus,UserId);
  }



}
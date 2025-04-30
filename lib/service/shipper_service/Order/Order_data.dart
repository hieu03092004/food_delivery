import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../model/shipper_model/order_model.dart';

class OrderService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<Order>> getOrders() async {
    final raw = await _supabaseClient.rpc('get_orders_with_details');
    //print('🔍 raw RPC result: $raw (type: ${raw.runtimeType})');

    // Nếu raw không phải List thì dừng luôn
    if (raw is! List) {
      print('⚠️ Unexpected RPC result, not a List: $raw');
      return [];
    }

    // Ép kiểu và parse
    final List<dynamic> data = raw as List<dynamic>;
    print('Parsed order data count: ${data.length}');
    return data
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }




  // Lấy đơn hàng theo trạng thái
  Future<List<Order>> getOrdersByStatus(String status) async {
    print("Status:${status}");
    try {
      final response = await _supabaseClient
          .rpc('get_orders_by_status', params: {'order_status': status});

      if (response.error != null) {
        throw response.error!;
      }
      print("Respone data2:"+response.data);
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching orders by status: $e');
      return [];
    }
  }
}
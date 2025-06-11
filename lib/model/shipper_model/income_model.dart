import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderShipping {
  final int orderId;
  final double shippingFee;

  OrderShipping({required this.orderId, required this.shippingFee});
}

class IncomeModel {
  final _supabase = Supabase.instance.client;

  Future<List<OrderShipping>> getOrdersByDate({
    required int shipperId,
    required DateTime date,
  }) async {
    try {
      final dayStr = DateFormat('yyyy-MM-dd').format(date);
      final res = await _supabase
          .from('orders')
          .select('order_id, shipping_fee')
          .eq('shipper_id', shipperId)
          .eq('status', 'delivered')
          .gte('order_date', '$dayStr 00:00:00')
          .lte('order_date', '$dayStr 23:59:59')
          .order('order_date', ascending: true);

      final data = res as List<dynamic>;
      return data.map((e) {
        return OrderShipping(
          orderId: e['order_id'] as int,
          shippingFee: (e['shipping_fee'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

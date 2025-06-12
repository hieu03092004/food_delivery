import 'package:food_delivery/model/customer_model/product_model.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class Order {
  final int orderId;
  final int customerId;
  final int? shipperId;
  final String? status;
  final DateTime orderDate;
  final double shippingFee;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.customerId,
    this.shipperId,
    this.status,
    required this.orderDate,
    required this.shippingFee,
    required this.items,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    final orderItems = (map['order_item'] as List<dynamic>? ?? [])
        .map((item) {
      // In hàm từ `map['product']` để lấy thông tin sản phẩm
      final productMap = item['product'] as Map<String, dynamic>;
      final product = Product.fromJson(productMap); // Tạo product từ Map
      return OrderItem(
        quantity: item['quantity'],
        product: product,
      );
    })
        .toList();

    return Order(
      orderId: map['order_id'],
      customerId: map['customer_id'],
      shipperId: map['shipper_id'],
      status: map['status'],
      orderDate: DateTime.parse(map['order_date']),
      shippingFee: map['shipping_fee'],
      items: orderItems,
    );
  }
}

class OrderItem {
  final int quantity;
  final Product product;

  OrderItem({
    required this.quantity,
    required this.product,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      quantity: map['quantity'],
      product: Product.fromJson(map['product']),
    );
  }
}
class OrderSnapshot {
  static final _supabase = Supabase.instance.client;

  static Future<List<Order>> fetchOrdersByCustomer(int accountId) async {
    final data = await _supabase
        .from('orders')
        .select(r'''
          *,
          order_item (
            quantity,
            product:product_id (
              *,
              store:store_id (*)
            )
          )
        ''')
        .eq('customer_id', accountId)
        .order('order_date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => Order.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Lấy chi tiết một đơn hàng (có nested order_item → product → store)
  static Future<Order> fetchOrderById(int orderId) async {
    final data = await _supabase
        .from('orders')
        .select(r'''
          *,
          order_item (
            quantity,
            product:product_id (
              *,
              store:store_id (*)
            )
          )
        ''')
        .eq('order_id', orderId)
        .single();
    return Order.fromMap(data as Map<String, dynamic>);
  }


}

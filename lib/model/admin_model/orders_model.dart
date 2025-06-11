import 'package:food_delivery/model/admin_model/product_model.dart';
import 'package:food_delivery/pages/admin_pages/supabase_helper.dart';

class Order {
  final int orderId;
  final int customerId;
  final int? shipperId;
  final String? status;
  final DateTime orderDate;
  final int shippingFee;
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
    final orderItems =
        (map['order_item'] as List<dynamic>? ?? []).map((item) {
          // In hàm từ `map['product']` để lấy thông tin sản phẩm
          final productMap = item['product'] as Map<String, dynamic>;
          final product = Product.fromMap(productMap); // Tạo product từ Map
          return OrderItem(quantity: item['quantity'], product: product);
        }).toList();

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

  OrderItem({required this.quantity, required this.product});

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      quantity: map['quantity'],
      product: Product.fromMap(map['product']),
    );
  }
}

class OrderSnapshot {
  static void listenDataChange(Map<int, Order> maps, {Function()? updateUI}) {
    listenDataChangeHelper<Order>(
      maps,
      table: "orders",
      channel: 'public:orders',
      fromJson: (json) => Order.fromMap(json),
      getID: (t) => t.orderId,
      updateUI: updateUI,
    );
  }

  /// Hủy đăng ký lắng nghe
  static void unsubscribeListenOrderChange() {
    supabase.channel('public:orders').unsubscribe();
  }

  static Future<Map<int, Order>> getOrder() async {
    return getMapData(
      table: "orders",
      fromJson: (json) => Order.fromMap(json),
      getID: (t) => t.orderId,
    );
  }

  static Stream<List<Order>> getOrderStream() {
    return supabase
        .from('orders')
        .select('*, order_item(quantity, product(*))')
        .asStream()
        .map((data) {
          print('Dữ liệu Supabase: $data');
          return data.map((json) => Order.fromMap(json)).toList();
        });
  }
}

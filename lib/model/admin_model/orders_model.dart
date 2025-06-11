import 'package:food_delivery/model/admin_model/product_model.dart';
import '../../pages/admin_pages/supabase_helper.dart';

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
    final orderItems = (map['order_item'] as List<dynamic>? ?? [])
        .map((item) {
      // In hàm từ `map['product']` để lấy thông tin sản phẩm
      final productMap = item['product'] as Map<String, dynamic>;
      final product = Product.fromMap(productMap); // Tạo product từ Map
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
      product: Product.fromMap(map['product']),
    );
  }
}

class OrderSnapshot {
  static final supabase = Supabase.instance.client;

  /// Lấy danh sách tất cả đơn hàng
  static Future<Map<int, Order>> getOrder() async {
    final response = await supabase
        .from('orders')
        .select('*, order_item(quantity, product(*))');

    final data = (response as List<dynamic>)
        .map((json) => Order.fromMap(json))
        .toList();

    return {for (var o in data) o.orderId: o};
  }

  /// Thêm đơn hàng mới
  static Future<void> insert(Order order) async {
    final orderMap = order.toMap();
    final response = await supabase
        .from('orders')
        .insert(orderMap)
        .select()
        .single();

    final newOrderId = response['order_id'];

    // Insert order items
    for (var item in order.items) {
      await supabase.from('order_item').insert({
        'order_id': newOrderId,
        'product_id': item.product.id,
        'quantity': item.quantity,
      });
    }
  }

  /// Cập nhật trạng thái hoặc thông tin đơn hàng
  static Future<void> update(Order order) async {
    await supabase
        .from('orders')
        .update(order.toMap())
        .eq('order_id', order.orderId);
  }

  /// Xoá đơn hàng và các order_item liên quan
  static Future<void> delete(int orderId) async {
    await supabase.from('order_item').delete().eq('order_id', orderId);
    await supabase.from('orders').delete().eq('order_id', orderId);
  }

  /// Lắng nghe thay đổi dữ liệu đơn hàng theo real-time
  static void listenDataChange(Map<int, Order> maps, {Function()? updateUI}) {
    listenDataChangeHelper<Order>(
      maps,
      table: "orders",
      channel: 'public:orders',
      fromJson: (json) => Order.fromMap(json),
      getID: (t) => t.orderId,
      updateUI: updateUI,
      selectColumns: '*, order_item(quantity, product(*))',
    );
  }

  /// Hủy đăng ký lắng nghe
  static void unsubscribeListenOrderChange() {
    supabase.channel('public:orders').unsubscribe();
  }

  /// Stream theo dõi đơn hàng
  static Stream<List<Order>> getOrderStream() {
    return supabase
        .from('orders')
        .select('*, order_item(quantity, product(*))')
        .asStream()
        .map((data) {
      return (data as List)
          .map((json) => Order.fromMap(json))
          .toList();
    });
  }

  /// Dữ liệu cache tạm
  static List<Order> data = [];

  static List<Order> getAll() => data;
}

class OrderSnapshot1 {
  static Future<Map<int, Order>> getOrder() async{
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
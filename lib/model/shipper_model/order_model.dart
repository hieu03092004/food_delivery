import '../../config/database.dart';

class Order {
  final int id;
  final int customerId;
  final String customerName;
  final String storeName;
  final String productName;
  final String description;
  final int quantity;
  final double originalPrice;
  final double discountedPrice;
  final String imageUrl;
  String status; // Trạng thái tiếng Anh trong DB
  String statusText; // Trạng thái tiếng Việt hiển thị trên UI
  final double shippingFee;
  final DateTime orderDate;
  double totalAmount; // Tổng tiền = (giá đã giảm * số lượng) + phí giao hàng

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.storeName,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.originalPrice,
    required this.discountedPrice,
    required this.imageUrl,
    required this.status,
    this.statusText = '', // Ban đầu để trống, sẽ được thiết lập sau
    required this.shippingFee,
    required this.orderDate,
    this.totalAmount = 0, // Ban đầu để 0, sẽ được tính toán sau
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['order_id'] ?? 0,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] ?? '',
      storeName: json['store_name'] ?? '',
      productName: json['product_name'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      originalPrice: (json['original_price'] ?? 0).toDouble(),
      discountedPrice: (json['discounted_price'] ?? 0).toDouble(),
      imageUrl: json['thumbnail_url'] ?? '',
      status: json['status'] ?? '',
      shippingFee: (json['shipping_fee'] ?? 0).toDouble(),
      orderDate:
          json['order_date'] != null
              ? DateTime.parse(json['order_date'])
              : DateTime.now(),
    );
  }
  @override
  String toString() {
    return 'Order('
        'id: $id, '
        'customer: $customerName, '
        'store: $storeName, '
        'product: $productName, '
        'qty: $quantity, '
        'status: $status'
        ')';
  }
}

class OrderWithItems {
  final int id;
  final int customerId;
  final String customerName;
  final String storeName;
  String status;
  String statusText;
  final double shippingFee;
  final DateTime orderDate;
  final List<Order> items;

  OrderWithItems({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.storeName,
    required this.status,
    required this.statusText,
    required this.shippingFee,
    required this.orderDate,
    required this.items,
  });

  int get totalProducts => items.fold(0, (sum, x) => sum + x.quantity);

  double get totalAmount =>
      items.fold(0.0, (sum, x) => sum + x.discountedPrice * x.quantity) +
      shippingFee;
  @override
  String toString() {
    return 'OrderWithItems('
        'id: $id, '
        'customerId: $customerId, '
        'customerName: $customerName, '
        'storeName: $storeName, '
        'status: $status, '
        'statusText: $statusText, '
        'shippingFee: $shippingFee, '
        'orderDate: $orderDate, '
        'totalProducts: $totalProducts, '
        'totalAmount: $totalAmount, '
        'items: $items'
        ')';
  }
}

class UpdateOrderResult {
  final bool success;
  final String message;
  final String? oldStatus;
  final String? newStatus;
  final String? newDbStatus;

  UpdateOrderResult({
    required this.success,
    required this.message,
    this.oldStatus,
    this.newStatus,
    this.newDbStatus,
  });
}

class OrderSnapshot {
  static Future<List<OrderWithItems>> getOrdersByStatus(
    String status,
    int shipperId,
  ) async {
    try {
      final raw = await Database.client.rpc(
        'get_orders_by_status',
        params: {'order_status': status, 'p_shipper_id': shipperId},
      );

      if (raw is! List) {
        print('⚠️ Unexpected RPC result, not a List: $raw');
        return [];
      }

      final flatOrders =
          (raw as List<dynamic>).map((json) {
            final o = Order.fromJson(json as Map<String, dynamic>);
            return o;
          }).toList();

      final Map<int, List<Order>> buffer = {};
      for (var o in flatOrders) {
        buffer.putIfAbsent(o.id, () => []).add(o);
      }

      return buffer.entries.map((e) {
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
    } catch (e) {
      print('Error fetching orders by status: $e');
      return [];
    }
  }

  static Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await Database.client
          .from('orders')
          .update({'status': newStatus})
          .eq('order_id', orderId);
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  static Future<String?> getCustomerDeviceToken(int customerId) async {
    try {
      final tokenRes =
          await Database.client
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

  static Future<bool> createNotification({
    required int recipientId,
    required int orderId,
    required String message,
    required String title,
  }) async {
    try {
      await Database.client.from('notification').insert({
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
}

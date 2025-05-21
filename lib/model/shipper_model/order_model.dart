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
      customerId:json['customer_id']     as int,
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
      orderDate: json['order_date'] != null
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

  int get totalProducts =>
      items.fold(0, (sum, x) => sum + x.quantity);

  double get totalAmount =>
      items.fold(0.0, (sum, x) => sum + x.discountedPrice * x.quantity)
          + shippingFee;
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

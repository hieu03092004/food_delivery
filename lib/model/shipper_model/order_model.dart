class Order {
  final String id;
  final String storeName;
  final String productName;
  final String description;
  final int quantity;
  final double originalPrice;
  final double discountPercentage;
  final double discountedPrice;  // Giá sau khi tính giảm giá
  final double totalAmount;      // Tổng tiền = discountedPrice * quantity
  final String imageUrl;
  final String statusText;
  final String customerName;     // Thêm tên người dùng

  Order({
    required this.id,
    required this.storeName,
    required this.productName,
    this.description = '',
    required this.quantity,
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.totalAmount,
    required this.imageUrl,
    required this.statusText,
    required this.customerName,
  });

  // Factory method để tạo Order từ map (JSON) từ Supabase
  factory Order.fromJson(Map<String, dynamic> json) {
    // Tính toán giá sau khi giảm giá
    final double originalPrice = json['original_price'] is int
        ? (json['original_price'] as int).toDouble()
        : json['original_price'];

    final double discountPercentage = json['discount_percentage'] is int
        ? (json['discount_percentage'] as int).toDouble()
        : json['discount_percentage'];

    final double discountedPrice = originalPrice * (1 - discountPercentage / 100);

    // Tính tổng tiền dựa trên giá đã giảm và số lượng
    final int quantity = json['quantity'] ?? 1;
    final double totalAmount = discountedPrice * quantity;

    return Order(
      id: json['order_id']?.toString() ?? '',
      storeName: json['store_name'] ?? '',
      productName: json['title'] ?? '',
      description: json['description'] ?? '',
      quantity: quantity,
      originalPrice: originalPrice,
      discountPercentage: discountPercentage,
      discountedPrice: discountedPrice,
      totalAmount: totalAmount,
      imageUrl: json['thumbnail'] ?? '',
      statusText: json['status'] ?? '',
      customerName: json['customer_name'] ?? '',
    );
  }
}
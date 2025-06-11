class OrderWithItems {
  final String id;
  final String status;
  final String storeName;
  final String customerName;
  final double shippingFee;
  final double totalAmount;
  final int totalProducts;
  final List<OrderItem> items;

  OrderWithItems({
    required this.id,
    required this.status,
    required this.storeName,
    required this.customerName,
    required this.shippingFee,
    required this.totalAmount,
    required this.totalProducts,
    required this.items,
  });

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'ready':
        return 'Sẵn sàng giao';
      case 'delivering':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'delivered_failed':
        return 'Giao thất bại';
      case 'canceled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});
}

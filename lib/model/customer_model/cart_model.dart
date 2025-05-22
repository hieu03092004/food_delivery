import 'package:food_delivery/model/customer_model/product_model.dart';

class CartItem {
  final int accountId;
  final int quantity;
  final Product product;

  CartItem({
    required this.accountId,
    required this.quantity,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    accountId: j['account_id'] is String ? int.parse(j['account_id']) : j['account_id'],
    quantity: j['quantity'] is String ? int.parse(j['quantity']) : j['quantity'],
    product: Product.fromJson(j['product']),
  );
}
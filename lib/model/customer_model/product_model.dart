// Product Model
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:intl/intl.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double discountPercentage;
  final String thumbnailURL;
  final bool isDeleted;
  final int storeID;
  final double price;
  final double discountedPrice;
  final String unit;
  final dynamic categoryName; // Thay đổi thành dynamic để xử lý cả String và int
  final Store store;  // nested

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.discountPercentage,
    required this.thumbnailURL,
    required this.isDeleted,
    required this.storeID,
    required this.price,
    required this.discountedPrice,
    required this.unit,
    required this.categoryName,
    required this.store,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Xử lý price có thể là String hoặc num
    final double priceValue = json['price'] is String
        ? double.parse(json['price'])
        : (json['price'] as num).toDouble();

    // Xử lý discount_percent có thể là String hoặc num
    final double discountPct = json['discount_percent'] is String
        ? double.parse(json['discount_percent'])
        : (json['discount_percent'] as num).toDouble();

    final double discountedPrice = priceValue * (1 - discountPct / 100);

    return Product(
      id: json['product_id'] is String ? int.parse(json['product_id']) : json['product_id'],
      name: json['name'] as String,
      description: json['description'],
      discountPercentage: discountPct,
      thumbnailURL: json['thumbnail_url'] ?? "anh mac dinh",
      isDeleted: json['is_deleted'] is String
          ? json['is_deleted'].toLowerCase() == 'true'
          : json['is_deleted'] as bool,
      storeID: json['store_id'] is String ? int.parse(json['store_id']) : json['store_id'],
      price: priceValue,
      discountedPrice: discountedPrice,
      unit: json['unit'] as String,
      categoryName: json['category_name'], // Không ép kiểu
      store: Store.fromJson(json['store']), // map từ nested select
    );
  }

  // Formatter for Vietnamese Dong
  static final NumberFormat _currencyFormat = NumberFormat.simpleCurrency(
    locale: 'vi_VN',
    decimalDigits: 0,
    name: 'đ',
  );

  String get priceText => _currencyFormat.format(price);
  String get discountedPriceText => _currencyFormat.format(discountedPrice);
}
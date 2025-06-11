import 'package:supabase_flutter/supabase_flutter.dart';
import '../../pages/admin_pages/supabase_helper.dart';

class Product {
  final int? id;
  final String name;
  final String description;
  final double discountPercent;
  final String thumbnailUrl;
  final bool isDeleted;
  final int storeId;
  final double price;
  final String unit;
  final String categoryName;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.discountPercent,
    required this.thumbnailUrl,
    required this.isDeleted,
    required this.storeId,
    required this.price,
    required this.unit,
    required this.categoryName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['product_id'] as int,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      discountPercent: (map['discount_percent'] ?? 0).toDouble(),
      thumbnailUrl: map['thumbnail_url'] ?? '',
      isDeleted: map['is_deleted'] ?? false,
      storeId: map['store_id'] as int,
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      categoryName: map['category_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'discount_percent': discountPercent,
      'thumbnail_url': thumbnailUrl,
      'is_deleted': isDeleted,
      'store_id': storeId,
      'price': price,
      'unit': unit,
      'category_name': categoryName,
    };
  }
}

class ProductSnapshot {
  static final supabase = Supabase.instance.client;

  static Future<Map<int, Product>> getProduct() async {
    return getMapData(
      table: "product",
      fromJson: (json) => Product.fromMap(json),
      getID: (t) => t.id!,
    );
  }

  /// Cập nhật sản phẩm
  static Future<void> update(Product newProduct) async {
    if (newProduct.id == null) {
      throw Exception("Sản phẩm không tồn tại.");
    }

    if (newProduct.name.isEmpty ||
        newProduct.price <= 0 ||
        newProduct.unit.isEmpty ||
        newProduct.categoryName.isEmpty) {
      throw Exception("Vui lòng cung cấp đầy đủ thông tin sản phẩm.");
    }
    await supabase
        .from('product')
        .update(newProduct.toMap())
        .eq('product_id', newProduct.id!);
  }

  /// Thêm sản phẩm mới
  static Future<void> insert(Product product) async {
    if (product.name.isEmpty ||
        product.price <= 0 ||
        product.unit.isEmpty ||
        product.categoryName.isEmpty) {
      throw Exception("Vui lòng cung cấp đầy đủ thông tin sản phẩm.");
    }
    await supabase.from('product').insert(product.toMap());
  }

  /// Xoá sản phẩm và ảnh đi kèm nếu có
  static Future<void> delete(int id) async {
    try {
      print('Đây là id nè: ${id}');
      await supabase.from('product').delete().eq('product_id', id);
      await deleteImage(bucket: "images", path: "food/product_$id.jpg");
    } catch (e) {
      print('Loi roi ahuhu:{e}');
    }
  }

  /// Danh sách sản phẩm trong cache tạm thời
  static List<Product> data = [];

  static List<Product> getAll() {
    return data;
  }

  /// Hủy lắng nghe realtime
  static void unsubscribeListenProductChange() {
    supabase.channel('public:product').unsubscribe();
  }

  /// Lắng nghe thay đổi realtime trên bảng product
  static void listenDataChange(Map<int, Product> maps, {Function()? updateUI}) {
    listenDataChangeHelper<Product>(
      maps,
      table: "product",
      channel: 'public:product',
      fromJson: (json) => Product.fromMap(json),
      getID: (t) => t.id!,
      updateUI: updateUI,
    );
  }

  /// Stream toàn bộ sản phẩm (theo dõi realtime)
  static Stream<List<Product>> getProductStream() {
    return getDataStream<Product>(
      table: "product",
      ids: ["product_id"],
      fromJson: (json) => Product.fromMap(json),
    );
  }
}

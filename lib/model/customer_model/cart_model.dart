import 'package:food_delivery/model/customer_model/product_model.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

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
    accountId: j['account_id'] is String
        ? int.parse(j['account_id'])
        : j['account_id'],
    quantity: j['quantity'] is String
        ? int.parse(j['quantity'])
        : j['quantity'],
    product: Product.fromJson(j['product']),
  );
}

class CartSnapshot {
  static final supabase = Supabase.instance.client;

  /// Lấy tất cả cart items của một account, không phân theo store
  static Future<List<CartItem>> getAll(int accountId) async {
    final data = await supabase
        .from('cart_detail')
        .select(r'''
          account_id,
          quantity,
          created_at,
          product:product_id (
            *,
            store:store (*)
          )
        ''')
        .eq('account_id', accountId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lấy danh sách CartItem theo store với nested select
  static Future<List<CartItem>> getCartItemsByStore(
      int accountId, int storeId) async {
    final data = await supabase
        .from('cart_detail')
        .select(r'''
          account_id,
          quantity,
          product:product_id (
            *,
            store:store (*)
          )
        ''')
        .eq('account_id', accountId)
        .eq('product.store_id', storeId)
        .neq('quantity', 0)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Stream realtime để UI tự động cập nhật khi cart thay đổi

  /// Kiểm tra sản phẩm đã có trong giỏ chưa, trả về CartItem hoặc null
  static Future<CartItem?> getExisting(
      int accountId, int productId) async {
    final data = await supabase
        .from('cart_detail')
        .select(r'''
          account_id,
          quantity,
          created_at,
          product:product_id (
            *,
            store:store (*)
          )
        ''')
        .eq('account_id', accountId)
        .eq('product_id', productId)
        .limit(1);

    if ((data as List).isNotEmpty) {
      return CartItem.fromJson(data.first as Map<String, dynamic>);
    }
    return null;
  }

  /// Đếm số sản phẩm khác nhau trong giỏ hàng
  static Future<int> getDistinctCount(int accountId) async {
    final response = await supabase
        .from('cart_detail')
        .select('product_id')
        .eq('account_id', accountId);

    final ids = (response as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['product_id'] as int)
        .toSet();

    return ids.length;
  }

  /// Thêm hoặc cập nhật số lượng sản phẩm
  static Future<void> insert(int accountId, int productId, int quantity) async {
    await supabase.from("cart_detail").insert({
      "account_id": accountId,
      "product_id": productId,
      "quantity": quantity
    });
  }
  /// Cập nhật số lượng sản phẩm trong giỏ
  static Future<void> updateQuantity(int accountId, int productId, int newQuantity) async {
    await supabase
        .from("cart_detail")
        .update({"quantity": newQuantity})
        .match({
      "account_id": accountId,
      "product_id": productId,
    });
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  static Future<void> deleteItem(int accountId, int productId) async {
    await supabase
        .from('cart_detail')
        .delete()
        .match({
      'account_id': accountId,
      'product_id': productId,
    });
  }

  /// Xóa toàn bộ giỏ hàng của user
  static Future<void> clearAll(int accountId) async {
    await supabase
        .from('cart_detail')
        .delete()
        .eq('account_id', accountId);
  }
}

import 'package:food_delivery/helpers/supabase_helper.dart';
import 'package:food_delivery/model/admin_model/orders_model.dart';
import 'package:food_delivery/model/customer_model/cart_model.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:get/get.dart';

class ControllerCart extends GetxController {
  AuthService get _auth => Get.find<AuthService>();
  int get accountID => _auth.accountId.value;

  /// Danh sách cart items
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  /// Số sản phẩm khác nhau trong giỏ (distinct)
  final RxInt distinctCount = 0.obs;

  /// Loading states
  final RxBool isLoading = false.obs;

  @override
  void onInit() {

    super.onInit();
    loadCartItems();
    loadDistinctCount();


  }

  /// Load tất cả cart items
  Future<void> loadCartItems() async {
    try {
      isLoading.value = true;
      print("id nè má: ${accountID}");
      final items = await CartSnapshot.getAll(accountID);
      cartItems.assignAll(items);
    } catch (error) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải giỏ hàng: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load số lượng sản phẩm khác nhau
  Future<void> loadDistinctCount() async {
    try {
      final count = await CartSnapshot.getDistinctCount(accountID);
      distinctCount.value = count;
    } catch (error) {
      print('Lỗi khi load distinct count: $error');
    }
  }

  /// Refresh toàn bộ data
  Future<void> reload() async {
    await Future.wait([
      loadCartItems(),
      loadDistinctCount(),
    ]);
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<void> addProductToCart(int productId, {int quantity = 1}) async {
    try {
      print(accountID);
      // Kiểm tra sản phẩm đã có trong giỏ chưa
      final existingItem = await CartSnapshot.getExisting(accountID, productId);

      if (existingItem != null) {
        // Đã có -> tăng quantity
        final newQuantity = existingItem.quantity + quantity;
        await CartSnapshot.updateQuantity(accountID, productId, newQuantity);

        // Cập nhật local state
        final index = cartItems.indexWhere((item) => item.product.id == productId);
        if (index != -1) {
          cartItems[index] = CartItem(
            accountId: cartItems[index].accountId,
            quantity: newQuantity,
            product: cartItems[index].product,
          );
        }
      } else {
        // Chưa có -> thêm mới
        await CartSnapshot.insert(accountID, productId, quantity);

        // Reload để có đầy đủ thông tin product
        await loadCartItems();
      }
      // Cập nhật distinct count
      await loadDistinctCount();

      Get.snackbar(
        'Thành công',
        'Đã thêm sản phẩm vào giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (error) {
      print(error);
      Get.snackbar(
        'Lỗi',
        'Không thể thêm sản phẩm vào giỏ: $error',
        snackPosition: SnackPosition.BOTTOM,

      );
    }
  }

  /// Cập nhật số lượng sản phẩm
  Future<void> updateQuantity(int productId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      await CartSnapshot.updateQuantity(accountID, productId, newQuantity);

      // Cập nhật local state
      final index = cartItems.indexWhere((item) => item.product.id == productId);
      if (index != -1) {
        cartItems[index] = CartItem(
          accountId: cartItems[index].accountId,
          quantity: newQuantity,
          product: cartItems[index].product,
        );
      }

    } catch (error) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật số lượng: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(int productId) async {
    try {
      await CartSnapshot.deleteItem(accountID, productId);

      // Cập nhật local state
      cartItems.removeWhere((item) => item.product.id == productId);

      // Cập nhật distinct count
      await loadDistinctCount();

      Get.snackbar(
        'Thành công',
        'Đã xóa sản phẩm khỏi giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (error) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa sản phẩm: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    try {
      await CartSnapshot.clearAll(accountID);
      cartItems.clear();
      distinctCount.value = 0;

      Get.snackbar(
        'Thành công',
        'Đã xóa toàn bộ giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (error) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa giỏ hàng: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  /// Xoá những sản phẩm (productIds) trong giỏ của user
  Future<void> clearCartForUser(int accountId, List<int> productIds) async {
    if (productIds.isEmpty) return;
    await supabase
        .from('cart_detail')
        .delete()
        .eq('account_id', accountId)
    // Sử dụng filter với operator 'in'
        .filter('product_id', 'in', productIds);
  }
  /// Tính tổng giá trị giỏ hàng
  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) =>
    sum + (item.product.discountedPrice * item.quantity));
  }

  /// Tính tổng số lượng sản phẩm
  int get totalQuantity {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Kiểm tra giỏ hàng có rỗng không
  bool get isEmpty => cartItems.isEmpty;

  /// Kiểm tra sản phẩm có trong giỏ không
  bool isProductInCart(int productId) {
    return cartItems.any((item) => item.product.id == productId);
  }

  /// Lấy số lượng của một sản phẩm trong giỏ
  int getProductQuantity(int productId) {
    final item = cartItems.firstWhereOrNull((item) => item.product.id == productId);
    return item?.quantity ?? 0;
  }
}
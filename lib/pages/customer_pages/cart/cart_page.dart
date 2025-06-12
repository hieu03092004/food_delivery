import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_delivery/model/customer_model/cart_model.dart';
import 'package:food_delivery/pages/customer_pages/checkout_page.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/controller_cart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:food_delivery/model/customer_model/store_model.dart';

import 'package:food_delivery/widget/default_appBar.dart';

class CartPage extends StatefulWidget {
  final accountId;
  CartPage({Key? key,required this.accountId}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ControllerCart carts = Get.find<ControllerCart>();


  // Trạng thái chọn toàn cục
  bool _allSelected = false;

  // Trạng thái chọn theo storeId
  final Map<int, bool> _storeSelected = {};

  // Trạng thái chọn theo itemKey (storeId-productId)
  final Map<String, bool> _itemSelected = {};

  @override
  void initState() {
    print('CartPage got accountId = ${widget.accountId}');
    super.initState();
    // Load cart items khi init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      carts.loadCartItems();
    });
  }

  // Tạo khóa duy nhất cho mỗi item
  String _getItemKey(int storeId, int productId) {
    return "$storeId-$productId";
  }

  // Khởi tạo state cho các items mới
  void _initializeStates(List<CartItem> items) {
    final Map<int, List<CartItem>> itemsByStore = _groupItemsByStore(items);

    for (var storeId in itemsByStore.keys) {
      _storeSelected.putIfAbsent(storeId, () => false);
      for (var item in itemsByStore[storeId]!) {
        final itemKey = _getItemKey(storeId, item.product.id);
        _itemSelected.putIfAbsent(itemKey, () => false);
      }
    }
  }

  // Gom items theo store
  Map<int, List<CartItem>> _groupItemsByStore(List<CartItem> items) {
    final Map<int, List<CartItem>> itemsByStore = {};

    for (var item in items) {
      final storeId = item.product.store.id;
      if (!itemsByStore.containsKey(storeId)) {
        itemsByStore[storeId] = [];
      }
      itemsByStore[storeId]!.add(item);
    }

    return itemsByStore;
  }

  // Lấy store map từ items
  Map<int, Store> _getStoreMap(List<CartItem> items) {
    final Map<int, Store> storeMap = {};

    for (var item in items) {
      final storeId = item.product.store.id;
      if (!storeMap.containsKey(storeId)) {
        storeMap[storeId] = item.product.store;
      }
    }

    return storeMap;
  }

  // Toggle chọn store
  void _toggleStoreSelection(int storeId, List<CartItem> storeItems) {
    final newVal = !_storeSelected[storeId]!;
    setState(() {
      _storeSelected[storeId] = newVal;
      // Cập nhật tất cả items thuộc store
      for (var item in storeItems) {
        final itemKey = _getItemKey(storeId, item.product.id);
        _itemSelected[itemKey] = newVal;
      }
      _updateAllSelectedState();
    });
  }

  // Toggle chọn item
  void _toggleItemSelection(String itemKey, int storeId, List<CartItem> storeItems) {
    setState(() {
      _itemSelected[itemKey] = !_itemSelected[itemKey]!;

      // Cập nhật state của store
      final allStoreItemsSelected = storeItems.every((item) {
        final key = _getItemKey(storeId, item.product.id);
        return _itemSelected[key] == true;
      });
      _storeSelected[storeId] = allStoreItemsSelected;

      _updateAllSelectedState();
    });
  }

  // Toggle chọn tất cả
  void _toggleAllSelection() {
    final newVal = !_allSelected;
    setState(() {
      _allSelected = newVal;
      _itemSelected.updateAll((key, _) => newVal);
      _storeSelected.updateAll((key, _) => newVal);
    });
  }

  // Cập nhật state "chọn tất cả"
  void _updateAllSelectedState() {
    final allItemsSelected = _itemSelected.isNotEmpty &&
        _itemSelected.values.every((selected) => selected);
    _allSelected = allItemsSelected;
  }

  // Cập nhật số lượng
  void _updateQuantity(int productId, int newQuantity) {
    carts.updateQuantity(productId, newQuantity);
  }

  // Xóa item khỏi giỏ
  void _removeItem(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có muốn xóa sản phẩm này khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              carts.removeFromCart(productId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // Tính tổng tiền của items được chọn
  double _calculateSelectedTotal(List<CartItem> items) {
    double total = 0.0;
    for (var item in items) {
      final itemKey = _getItemKey(item.product.store.id, item.product.id);
      if (_itemSelected[itemKey] == true) {
        total += item.product.discountedPrice * item.quantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Giỏ hàng',
        showCartIcon: false,
      ),
      backgroundColor: Colors.grey[200],
      body: Obx(() {
        if (carts.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = carts.cartItems;
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Giỏ hàng trống', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        // Khởi tạo states
        _initializeStates(items);

        final itemsByStore = _groupItemsByStore(items);
        final storeMap = _getStoreMap(items);

        return RefreshIndicator(
          onRefresh: () => carts.reload(),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // Tạo section cho từng cửa hàng
              for (var storeId in itemsByStore.keys)
                _buildStoreSection(
                  storeMap[storeId]!,
                  itemsByStore[storeId]!,
                ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() => _buildBottomBar()),
    );
  }

  Widget _buildStoreSection(Store store, List<CartItem> items) {
    final storeChecked = _storeSelected[store.id] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header của store
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: storeChecked,
                onChanged: (_) => _toggleStoreSelection(store.id, items),
              ),
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        store.imageURL,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 24),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        store.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Danh sách item thuộc store
        ...items.map((item) => _buildCartItemRow(store.id, item)).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCartItemRow(int storeId, CartItem item) {
    final itemKey = _getItemKey(storeId, item.product.id);
    final isChecked = _itemSelected[itemKey] ?? false;
    final prod = item.product;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Slidable(

        key: ValueKey(itemKey),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(

              onPressed: (_) => _removeItem(item.product.id),

              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Xóa',
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (v) => _toggleItemSelection(
                itemKey,
                storeId,
                carts.cartItems.where((i) => i.product.store.id == storeId).toList(),
              ),
            ),

            // Hình ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                prod.thumbnailURL,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prod.unit,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // Điều khiển số lượng
                  Row(
                    children: [
                      GestureDetector(
                        onTap: item.quantity > 1
                            ? () => _updateQuantity(prod.id, item.quantity - 1)
                            : () => _removeItem(prod.id),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                            size: 18,
                            color: item.quantity > 1 ? Colors.grey[700] : Colors.red,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _updateQuantity(prod.id, item.quantity + 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Giá sản phẩm
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (prod.discountPercentage > 0) ...[
                  // Giá đã giảm
                  Text(
                    prod.discountedPriceText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Giá gốc
                  Text(
                    prod.priceText,
                    style: const TextStyle(
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),

                  // Phần trăm giảm giá
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-${prod.discountPercentage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else ...[
                  // Không có giảm giá
                  Text(
                    prod.priceText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final items = carts.cartItems;
    if (items.isEmpty) return const SizedBox.shrink();

    final selectedTotal = _calculateSelectedTotal(items);
    final hasSelectedItems = _itemSelected.values.any((selected) => selected);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Checkbox chọn tất cả
            Checkbox(
              value: _allSelected,
              onChanged: (_) => _toggleAllSelection(),
            ),
            const Text('Tất cả'),
            const Spacer(),

            // Tổng tiền
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(selectedTotal)} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Nút mua hàng
            ElevatedButton(
              onPressed: hasSelectedItems
                  ? () {
                // Xử lý thanh toán
                _handleCheckout();
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Mua ngay',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckout() {
    final selectedItems = <CartItem>[];
    final items = carts.cartItems;

    for (var item in items) {
      final itemKey = _getItemKey(item.product.store.id, item.product.id);
      if (_itemSelected[itemKey] == true) {
        selectedItems.add(item);
      }
    }

    if (selectedItems.isEmpty) {
      Get.snackbar(
        'Thông báo',
        'Vui lòng chọn sản phẩm để thanh toán',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(() => CheckoutPage(selectedItems: selectedItems));

    Get.snackbar(
      'Thông báo',
      'Chuyển đến trang thanh toán với ${selectedItems.length} sản phẩm',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:food_delivery/model/customer_model/cart_model.dart';
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:food_delivery/widget/default_appBar.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  final int accountId;
  const CartPage({Key? key, required this.accountId}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cartService = Get.find<CartService>();
  late Future<List<CartItem>> _futureItems;
  // trạng thái chọn toàn cục
  bool _allSelected = false;
  // trạng thái chọn theo storeId
  final Map<int, bool> _storeSelected = {};
  // trạng thái chọn theo itemIndex và storeId
  final Map<String, bool> _itemSelected = {};
  // trạng thái quantity theo itemIndex và storeId
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _futureItems = cartService.fetchCartItems(widget.accountId);
  }

  // Tạo khóa duy nhất cho mỗi item dựa trên storeId và productId
  String _getItemKey(int storeId, int productId) {
    return "$storeId-$productId";
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final cartService = Get.find<CartService>();
    return Scaffold(
      appBar: CommonAppBar(title: 'Giỏ hàng', showCartIcon: false),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<List<CartItem>>(
        future: _futureItems,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('Giỏ hàng trống'));

          // Tạo Map để gom các sản phẩm theo storeId
          final Map<int, Store> storeMap = {};
          final Map<int, List<CartItem>> itemsByStore = {};

          // Lặp qua từng CartItem và gom chúng theo storeId
          for (var item in items) {
            final storeId = item.product.store.id;

            // Lưu thông tin Store
            if (!storeMap.containsKey(storeId)) {
              storeMap[storeId] = item.product.store;
            }

            // Thêm item vào danh sách của store tương ứng
            if (!itemsByStore.containsKey(storeId)) {
              itemsByStore[storeId] = [];
            }
            itemsByStore[storeId]!.add(item);
          }

          // 2) Khởi tạo state mặc định cho tất cả các items
          for (var storeId in itemsByStore.keys) {
            _storeSelected.putIfAbsent(storeId, () => false);
            for (var item in itemsByStore[storeId]!) {
              final itemKey = _getItemKey(storeId, item.product.id);
              _itemSelected.putIfAbsent(itemKey, () => false);
              _quantities.putIfAbsent(itemKey, () => item.quantity);
            }
          }

          // 3) Xây dựng giao diện
          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // Tạo section cho từng cửa hàng
              for (var storeId in itemsByStore.keys)
                _buildStoreSection(
                  storeMap[storeId]!,
                  itemsByStore[storeId]!,
                  () {
                    // Toggle chọn toàn bộ items của store
                    final newVal = !_storeSelected[storeId]!;
                    setState(() {
                      _storeSelected[storeId] = newVal;
                      // Cập nhật từng item thuộc store này
                      for (var item in itemsByStore[storeId]!) {
                        final itemKey = _getItemKey(storeId, item.product.id);
                        _itemSelected[itemKey] = newVal;
                      }
                    });
                  },
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStoreSection(
    Store store,
    List<CartItem> items,
    VoidCallback onStoreToggle,
  ) {
    final storeChecked = _storeSelected[store.id]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header của store
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Checkbox(value: storeChecked, onChanged: (_) => onStoreToggle()),
              Text(
                store.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Danh sách item thuộc store
        ...items.map((item) {
          final itemKey = _getItemKey(store.id, item.product.id);
          final isChecked = _itemSelected[itemKey] ?? false;
          final qty = _quantities[itemKey] ?? item.quantity;

          return _buildCartItemRow(itemKey, isChecked, qty, item);
        }).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCartItemRow(
    String itemKey,
    bool isChecked,
    int qty,
    CartItem item,
  ) {
    final prod = item.product;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (v) => setState(() => _itemSelected[itemKey] = v!),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              prod.thumbnailURL,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prod.name, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          qty > 1
                              ? () =>
                                  setState(() => _quantities[itemKey] = qty - 1)
                              : null,
                    ),
                    Text('$qty', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed:
                          () => setState(() => _quantities[itemKey] = qty + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            children: [
              if (prod.discountPercentage > 0.0) ...[
                // Giá đã giảm (nổi bật)
                Text(
                  '${prod.discountedPriceText}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepOrange,
                  ),
                ),

                const SizedBox(height: 4),

                // Giá gốc (gạch ngang, nhỏ hơn, xám)
                Text(
                  '${prod.priceText}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                // Không có giảm giá: chỉ giá gốc
                Text(
                  '${prod.priceText}',
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
    );
  }

  Widget _buildBottomBar() {
    // Kiểm tra xem tất cả các sản phẩm có được chọn không
    final allChecked =
        _itemSelected.isNotEmpty && _itemSelected.values.every((v) => v);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Checkbox(
            value: allChecked,
            onChanged: (v) {
              final newVal = v!;
              setState(() {
                _allSelected = newVal;
                // Cập nhật tất cả các items
                _itemSelected.updateAll((key, _) => newVal);
                // Cập nhật tất cả các store
                _storeSelected.updateAll((key, _) => newVal);
              });
            },
          ),
          const Text('Tất cả'),
          const Spacer(),
          FutureBuilder<List<CartItem>>(
            future: _futureItems,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Tính toán...');

              double total = 0.0;
              final items = snapshot.data!;

              for (var item in items) {
                final itemKey = _getItemKey(
                  item.product.store.id,
                  item.product.id,
                );
                if (_itemSelected[itemKey] == true) {
                  final qty = _quantities[itemKey] ?? item.quantity;
                  total += item.product.discountedPrice * qty;
                }
              }

              return Text(
                'Tổng cộng ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(total)} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Xử lý khi nhấn nút Mua hàng
            },
            child: const Text('Mua ngay'),
          ),
        ],
      ),
    );
  }
}

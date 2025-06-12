import 'package:flutter/material.dart';
import 'package:food_delivery/model/customer_model/cart_model.dart';
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:food_delivery/pages/customer_pages/orderDetail_page.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/controller_cart.dart';
import 'package:food_delivery/service/customer_service/controller_order.dart';
import 'package:food_delivery/widget/default_appBar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class CheckoutPage extends StatefulWidget {
  final List<CartItem> selectedItems;
  const CheckoutPage({Key? key, required this.selectedItems}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Color themeOrange = Color(0xFFEE4D2D);
  final auth = Get.find<AuthService>();
  bool _isLoading = false;
  String? _address;
  final moneyFmt = NumberFormat.simpleCurrency(
    locale: 'vi_VN', decimalDigits: 0, name: 'đ',
  );
  Map<int, Store> _storeMap = {};

  @override
  void initState() {
    super.initState();
    _loadAddress();
    _loadStores();
  }

  Future<void> _loadStores() async {
    // Lấy toàn bộ stores từ Supabase
    final m = await StoreSnapshot.getMapStores();
    setState(() => _storeMap = m);
  }
  Future<void> _loadAddress() async {
    // Giả sử AuthService có method getAddress()
    final addr = await auth.addressAccount.value;
    print("địa chỉ nè: ${addr}");
    setState(() => _address = addr);
  }

  double get _productTotal =>
      widget.selectedItems.fold(0.0, (sum, ci) => sum + ci.product.discountedPrice * ci.quantity);

  /// Lấy phí ship từng cửa hàng từ _storeMap
  double get _shippingFee {
    if (_storeMap.isEmpty) return 0;

    // Nhóm items theo store và tính phí ship cho từng store
    final storeGroups = <int, List<CartItem>>{};
    for (final item in widget.selectedItems) {
      final storeId = item.product.store.id;
      storeGroups.putIfAbsent(storeId, () => []).add(item);
    }

    double totalShippingFee = 0;
    storeGroups.forEach((storeId, items) {
      final store = _storeMap[storeId];
      if (store != null) {
        // Tính tổng tiền của store này
        final storeTotal = items.fold(0.0,
                (sum, item) => sum + item.product.discountedPrice * item.quantity);

        // Phí ship = tổng tiền store * % phí ship
        final shippingRate = (store.shipperCommission ?? 0).toDouble();
        totalShippingFee += storeTotal * shippingRate;
      }
    });

    return totalShippingFee;
  }

  double get _grandTotal => _productTotal + _shippingFee;

  Future<void> _confirmOrder() async {
    if (_address == null) return;
    setState(() => _isLoading = true);

    try {
      print('=== DEBUG INFO ===');
      print('Product total: $_productTotal (${_productTotal.runtimeType})');
      print('Shipping fee: $_shippingFee (${_shippingFee.runtimeType})');
      print('Grand total: $_grandTotal (${_grandTotal.runtimeType})');

      // Debug từng item
      for (int i = 0; i < widget.selectedItems.length; i++) {
        final item = widget.selectedItems[i];
        print('Item $i:');
        print('  - Price: ${item.product.discountedPrice} (${item.product.discountedPrice.runtimeType})');
        print('  - Quantity: ${item.quantity} (${item.quantity.runtimeType})');
        print('  - Total: ${item.product.discountedPrice * item.quantity}');
      }

      print('=== CALLING placeOrderCOD ===');
      final order = await ControllerOrder().placeOrderCOD(
        items: widget.selectedItems,
        shippingFee: _shippingFee,
      );

      print('Order result: $order');

      if (order == null) {
        Get.snackbar('Lỗi', 'Không thể tạo đơn hàng',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Sau khi tạo đơn thành công, clear cart
      final selIds = widget.selectedItems.map((ci) => ci.product.id).toList();
      await Get.find<ControllerCart>()
          .clearCartForUser(auth.accountId.value, selIds);

      // Chuyển đến trang chi tiết đơn (có thể)
      Get.off(() => OrderDetailPage(order: order!));
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tạo đơn: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Xác nhận đơn hàng'),
      body: _address == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Giao đến:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_address!),
            const Divider(height: 32),

            Text('Chi tiết sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: widget.selectedItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, idx) {
                  final ci = widget.selectedItems[idx];
                  return Row(
                    children: [
                      Expanded(child: Text(ci.product.name)),
                      Text('x${ci.quantity}'),
                      const SizedBox(width: 12),
                      Text(moneyFmt.format(ci.product.discountedPrice * ci.quantity)),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 32),

            // Tổng cộng
            // Tổng tiền hàng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng tiền hàng:'),
                Text(moneyFmt.format(_productTotal)),
              ],
            ),
            const SizedBox(height: 8),

// Phí ship truy vấn từ store
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phí ship:'),
                Text(moneyFmt.format(_shippingFee)),
              ],
            ),
            const SizedBox(height: 8),

// Tổng cộng (cả ship)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  moneyFmt.format(_grandTotal),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nút xác nhận
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeOrange
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Thanh toán khi nhận hàng',style:  TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

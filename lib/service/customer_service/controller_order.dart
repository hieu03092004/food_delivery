import 'package:food_delivery/model/customer_model/order_model.dart';
import 'package:food_delivery/model/customer_model/cart_model.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ControllerOrder extends GetxController {
  final _supabase = Supabase.instance.client;
  AuthService get _auth => Get.find<AuthService>();
  int get accountId => _auth.accountId.value;

  final cartItems = <CartItem>[].obs;
  final distinctCount = 0.obs;
  final isLoadingCart = false.obs;
  final orders = <Order>[].obs;
  final isLoadingOrders = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
    loadDistinctCount();
    loadOrders();

  }

  Future<Order?> placeOrderCOD({
    required List<CartItem> items,
    required double shippingFee,
  }) async {
    if (accountId == 0) {
      Get.snackbar('Lỗi', 'Bạn cần đăng nhập trước khi đặt hàng');
      return null;
    }

    try {
      isLoadingOrders.value = true;

      final orderResp = await _supabase.from('orders').insert({
        'customer_id': accountId,
        'shipper_id': null,
        'status': 'pending',
        'order_date': DateTime.now().toIso8601String(),
        'shipping_fee': shippingFee,
      }).select('order_id, order_date').single();

      final orderId = orderResp['order_id'] as int;
      final orderDate = DateTime.parse(orderResp['order_date'] as String);

      for (var item in items) {
        await _supabase.from('order_item').insert({
          'order_id': orderId,
          'product_id': item.product.id,
          'quantity': item.quantity,
        });
      }

      final productIds = items.map((ci) => ci.product.id).toList();
      if (productIds.isNotEmpty) {
        await _supabase
            .from('cart_detail')
            .delete()
            .eq('account_id', accountId)
            .filter('product_id', 'in', productIds);
      }

      await reloadAll();

      final orderItems = items
          .map((ci) => OrderItem(quantity: ci.quantity, product: ci.product))
          .toList();

      final order = Order(
        orderId: orderId,
        customerId: accountId,
        shipperId: null,
        status: 'pending',
        orderDate: orderDate,
        shippingFee: shippingFee,
        items: orderItems,
      );

      Get.snackbar('Thành công', 'Đã đặt hàng #$orderId thành công!',
          backgroundColor: Colors.green[600], colorText: Colors.white);

      return order;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đặt hàng: $e',
          backgroundColor: Colors.red[600], colorText: Colors.white);
      return null;
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> loadCartItems() async {
    if (accountId == 0) return;
    isLoadingCart.value = true;
    cartItems.assignAll(await CartSnapshot.getAll(accountId));
    isLoadingCart.value = false;
  }

  Future<void> loadDistinctCount() async {
    if (accountId == 0) return;
    distinctCount.value = await CartSnapshot.getDistinctCount(accountId);
  }

  Future<void> loadOrders() async {
    if (accountId == 0) {
      orders.clear();
      return;
    }
    isLoadingOrders.value = true;
    final data = await _supabase
        .from('orders')
        .select(r"""
          *,
          order_item (
            quantity,
            product:product_id (
              *,
              store:store_id (*)
            )
          )
        """)
        .eq('customer_id', accountId)
        .order('order_date', ascending: false);

    final safeOrders = (data as List).map((orderData) {
      final safeMap = Map<String, dynamic>.from(orderData as Map<String, dynamic>);
      if (safeMap['shipping_fee'] != null) {
        safeMap['shipping_fee'] = (safeMap['shipping_fee'] as num).toDouble();
      }
      if (safeMap['total_amount'] != null) {
        safeMap['total_amount'] = (safeMap['total_amount'] as num).toDouble();
      }
      return Order.fromMap(safeMap);
    }).toList();

    orders.assignAll(safeOrders);
    isLoadingOrders.value = false;
  }

  Future<void> reloadAll() async {
    await Future.wait([
      loadCartItems(),
      loadDistinctCount(),
      loadOrders(),
    ]);
  }
}

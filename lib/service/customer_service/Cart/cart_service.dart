import 'dart:convert';

import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/model/customer_model/cart_model.dart';
import 'package:food_delivery/pages/authentication/PageAuthUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

/// Service to manage cart for both guest and authenticated users
class CartService extends GetxController {
  final supabase = Supabase.instance.client;

  Future<List<CartItem>> fetchCartItems(int accountId) async {
    try {
      final List<dynamic> rawList = await supabase
          .from('cart_detail')
          .select(r'''
        account_id,
        quantity,
        created_at,
        product:product_id (
          product_id,
          name,
          description,
          discount_percent,
          thumbnail_url,
          is_deleted,
          store_id,
          price,
          unit,
          category_name,
          store:store (
            store_id,
            name,
            address,
            image_url,
            open_time,
            close_time,
            shipper_commission
          )
        )
      ''')
          .eq('account_id', accountId)
          .order('created_at', ascending: false);

      // --- chỗ này in ra từng bản ghi và kiểm tra null
      for (var i = 0; i < rawList.length; i++) {
        final prod = (rawList[i] as Map<String, dynamic>)['product'] as Map<
            String,
            dynamic>;
        print('product_id type: ${prod['product_id'].runtimeType}');
        print('store_id type: ${prod['store']['store_id'].runtimeType}');
        print('shipper_commission type: ${prod['store']['shipper_commission']
            .runtimeType}');
      }

      // Sau khi in xong, parse về model
      return rawList
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw Exception('Không load được cart items: $error');
    }
  }



  /// số sản phẩm khác nhau trong giỏ (distinct)
  final RxInt distinctCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final rawList = await supabase
        .from('cart_detail')
        .select('product_id')
        .eq('account_id', Get.find<AuthService>().accountId.value);
    final ids = rawList.map((e) => (e as Map<String, dynamic>)['product_id'] as int).toSet();
    distinctCount.value = ids.length;
  }

  /// Gọi sau khi thêm/xóa cart để cập nhật badge
  Future<void> reload() => _loadCount();


  /// 2. Logic thêm sản phẩm vào giỏ (add 1 vào quantity nếu đã có)
  ///
  Future<void> addProductToCart(int accountId, int productId) async {
    // 2.1. Kiểm tra record hiện tại (accountId, productId)
    final List<dynamic> existing = await supabase
        .from('cart_detail')
        .select('quantity')
        .eq('account_id', accountId)
        .eq('product_id', productId)
        .limit(1);

    if (existing.isNotEmpty) {
      // 2.2. Đã có -> tăng quantity
      final int currentQty = (existing.first['quantity'] as num).toInt();
      final res = await supabase
          .from('cart_detail')
          .update({'quantity': currentQty + 1})
          .match({
        'account_id': accountId,
        'product_id': productId,
      });

      if (res.error != null) {
        throw Exception('Không thể cập nhật giỏ hàng: ${res.error!.message}');
      }
    } else {
      // 2.3. Chưa có -> insert mới với quantity = 1
      final res = await supabase
          .from('cart_detail')
          .insert({
        'account_id': accountId,
        'product_id': productId,
        'quantity': 1,
      });
      reload();
      print("Đã cập nhật");

      if (res.error != null) {
        print("Lỗi rồi");
        throw Exception('Không thể thêm sản phẩm vào giỏ: ${res.error!.message}');
      }
    }
  }

}


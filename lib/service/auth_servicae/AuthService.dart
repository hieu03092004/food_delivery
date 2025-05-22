import 'package:flutter/material.dart';
import 'package:food_delivery/pages/admin_pages/Bottom_nav_admin.dart';
import 'package:food_delivery/pages/customer_pages/bottom_customer_nav.dart';
import 'package:food_delivery/pages/shipper_pages/Bottom_nav_shipper.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:get/get.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';



class AuthService extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// accountId = 0 nghĩa là chưa login
  final RxInt accountId = 0.obs;
  final RxString roleName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự thay đổi auth state
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        await handleSignIn(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _handleSignOut();
      }
    });
    // Nếu đã có session khi app khởi động, GetX vẫn phát event signedIn
  }

  Future<void> handleSignIn(String userUUID) async {
    print(userUUID);
    final resp = await _supabase
        .from('account')
        .select('account_id, role_name')
        .eq('user_id', userUUID)
        .single();

    // resp là PostgrestMap, tương đương Map<String, dynamic>
    final record = resp as Map<String, dynamic>;

    accountId.value = (record['account_id'] as num).toInt();
    roleName.value  = record['role_name']   as String;
    print("đã đăng nhập");
    print(roleName.value);
    print(accountId.value);
    final cartService = Get.find<CartService>();
    await cartService.reload();

    update();

    update();
    // Điều hướng theo role, thay thế toàn bộ stack
    switch (roleName.value) {
      case 'admin':
        Get.offAll(() => BottomNavAdmin());
        break;
      case 'shipper':
        Get.offAll(() => BottomNavShipper());
        break;
      default:
        Get.offAll(() => BottomCustomerNav());
        break;
    }
    update();

  }

  void _handleSignOut() {
    accountId.value = 0;
    roleName.value  = '';
    update();
    // Quay về guest home
    Get.offAll(() => BottomCustomerNav());
  }

  bool get isLoggedIn => accountId.value != 0;
}

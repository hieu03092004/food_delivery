import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/pages/admin_pages/Bottom_nav_admin.dart';
import 'package:food_delivery/pages/customer_pages/bottom_customer_nav.dart';
import 'package:food_delivery/pages/shipper_pages/Bottom_nav_shipper.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:get/get.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../../model/shipper_model/Notification_model.dart';
class AuthService extends GetxController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// accountId = 0 nghĩa là chưa login
  final RxInt accountId = 0.obs;
  final RxString roleName = ''.obs;
  final RxInt storeId = 0.obs;

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
  }

  Future<void> handleSignIn(String userUUID) async {
    print('🔥 HandleSignIn started with UUID: $userUUID');

    try {
      final resp = await _supabase
          .from('account')
          .select('account_id, role_name, store_id')
          .eq('user_id', userUUID)
          .single();

      final record = resp as Map<String, dynamic>;
      final newAccountId = (record['account_id'] as num).toInt();
      final newRoleName = record['role_name'] as String;
      final newStoreId = record['store_id'] as num?;

      print(' Record: $record');
      print('New Account ID: $newAccountId');

      // Cập nhật thông tin account
      accountId.value = newAccountId;
      roleName.value = newRoleName;
      if (newStoreId != null) {
        storeId.value = newStoreId.toInt();
      }

      // XỬ LÝ NOTIFICATION PROVIDER Ở ĐÂY
      await _setupNotificationProvider(newAccountId);

      // Xử lý FCM token
      await _handleFCMToken(newAccountId);

      // Reload cart
      final cartService = Get.find<CartService>();
      await cartService.reload();

      // Điều hướng theo role
      _navigateByRole(newRoleName, newStoreId?.toInt());

      update();
      print(' HandleSignIn completed');

    } catch (e) {
      print(' Error in handleSignIn: $e');
    }
  }

  // Tách riêng việc setup NotificationProvider
  Future<void> _setupNotificationProvider(int accountId) async {
    print('🔔 Setting up NotificationProvider for accountId: $accountId');

    // Nếu có instance cũ, xóa đi
    if (Get.isRegistered<NotificationProvider>()) {
      print('🗑️ Deleting old NotificationProvider');
      Get.delete<NotificationProvider>();
    }

    // Tạo instance mới với accountId đúng
    print('🆕 Creating new NotificationProvider with userId: $accountId');
    Get.put(NotificationProvider(accountId), permanent: true);

    // Fetch unread count CHỈ MỘT LẦN
    print('📬 Fetching unread count...');
    await Get.find<NotificationProvider>().fetchUnreadCount();
  }

  Future<void> _handleFCMToken(int accountId) async {
    final fcmToken = await _messaging.getToken();
    if (fcmToken == null) {
      print('❌ Không lấy được FCM token');
      return;
    }

    print('[FCM] Token = $fcmToken');

    try {
      await _supabase
          .from('account')
          .update({'tokendevice': fcmToken})
          .eq('account_id', accountId);
      print('[DB] Updated tokenDevice for account_id=$accountId');
    } catch (e) {
      print('[DB] Error updating tokenDevice: $e');
    }
  }

  void _navigateByRole(String role, int? storeId) {
    print('🧭 Navigating by role: $role');

    switch (role) {
      case 'admin':
        Get.offAll(() => BottomNavAdmin(storeId: storeId ?? 0));
        break;
      case 'shipper':
        Get.offAll(() => BottomNavShipper());
        break;
      default:
        Get.offAll(() => BottomCustomerNav());
        break;
    }
  }

  Future<void> signOut() async {
    try {
      print('🚪 Starting sign out process...');

      // Gọi Supabase signOut để xóa session
      await _supabase.auth.signOut();

      // _handleSignOut sẽ được gọi tự động thông qua onAuthStateChange listener
      print('✅ Sign out completed');

    } catch (e) {
      print('❌ Error during sign out: $e');
      // Nếu có lỗi với Supabase, vẫn thực hiện cleanup local
      _handleSignOut();
      rethrow; // Ném lại lỗi để UI có thể handle
    }
  }

  // Cập nhật lại hàm _handleSignOut để hoàn thiện hơn
  void _handleSignOut() {
    print('👋 Handle sign out - Cleaning up local data');

    // Reset values
    accountId.value = 0;
    roleName.value = '';
    storeId.value = 0;

    // Xóa NotificationProvider
    if (Get.isRegistered<NotificationProvider>()) {
      print('🗑️ Deleting NotificationProvider');
      Get.delete<NotificationProvider>();
    }

    // Clear cart nếu có
    if (Get.isRegistered<CartService>()) {
      try {
        final cartService = Get.find<CartService>();
        update(); // Tạo method này trong CartService nếu chưa có
      } catch (e) {
        print('⚠️ Error clearing cart: $e');
      }
    }

    update();

    // Quay về guest home
    print('🏠 Navigating to guest home');
    Get.offAll(() => BottomCustomerNav());
  }

  bool get isLoggedIn => accountId.value != 0;
}


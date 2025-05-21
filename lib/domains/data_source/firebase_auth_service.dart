import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/database.dart';
// lib/domains/authentication_respository/auth_result.dart

class AuthResult {
  final int uid;
  final String email;
  final String roleName;
  final int? storeId;      // ← thêm storeId

  AuthResult({
    required this.uid,
    required this.email,
    required this.roleName,
    this.storeId,          // ← optional
  });
}

class FireBaseAuthService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try{
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Nếu không throw, nghĩa là thành công
      final user = credential.user!;
      final userEmail = user.email!;

      print(userEmail);

      // 1) Lấy client từ class Database
      final supabase = Database.client;

      // 2) Thực hiện truy vấn
      final res = await supabase
          .from('account')
          .select('role_name, store_id,account_id')
          .eq('email', userEmail)
          .single();
      // 3) Kiểm tra lỗi
      print("res:${res}");
      print('⚠️ [Auth] Login success user for email=$userEmail');
      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        print('❌ Không lấy được FCM token');
      } else {
        print('[FCM] Token = $fcmToken');
      }

      final String roleName  = res['role_name'] as String;
      final int? storeId = res['store_id'] as int?;
      final int accountId    = res['account_id'] as int;
      if (fcmToken != null) {
        final updateCount = await supabase
            .from('account')
            .update({'tokendevice': fcmToken})
            .eq('account_id', accountId);
        print('[DB] Updated tokenDevice for account_id=$accountId; result=$updateCount');
      }
// Trả về AuthResult với uid là int
      return AuthResult(
        uid:     accountId,
        email:   user.email!,
        roleName:  roleName,
        storeId: storeId,
      );
    }
    on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e, st) {
      print('❌ Lỗi không phải AuthException: $e');
      print(st);
      rethrow;
    }// Thực hiện đăng nhập
  }
}
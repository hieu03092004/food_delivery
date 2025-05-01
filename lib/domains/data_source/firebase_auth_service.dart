import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/database.dart';
// lib/domains/authentication_respository/auth_result.dart

class AuthResult {
  final String uid;
  final String email;
  final int roleId;
  final int? storeId;      // ← thêm storeId

  AuthResult({
    required this.uid,
    required this.email,
    required this.roleId,
    this.storeId,          // ← optional
  });
}

class FireBaseAuthService {
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
      // Thực hiện đăng nhập
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Nếu không throw, nghĩa là thành công
      final user = credential.user!;
      final userEmail = user.email!;
      final userUid   = user.uid;
      print(userEmail);
      print(userUid);

      // 1) Lấy client từ class Database
      final supabase = Database.client;

      // 2) Thực hiện truy vấn
      final res = await supabase
          .from('account')
          .select('role_id, store_id')
          .eq('email', userEmail)
          .single();

      // 3) Kiểm tra lỗi
     print("res:${res}");
     print('⚠️ [Auth] Login success user for email=$userEmail');
      final int roleId  = res['role_id'] as int;
      final int? storeId = res['store_id'] as int?;
      print('✅ role_id=$roleId, store_id=$storeId');
      return AuthResult(
        uid: user.uid,
        email: user.email!,
        roleId: roleId,
        storeId: storeId,        // ← trả về storeId luôn
      );

  }
}
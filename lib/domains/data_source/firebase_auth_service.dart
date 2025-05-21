import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/database.dart';
// lib/domains/authentication_respository/auth_result.dart

class AuthResult {
  final String uid;
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
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try{
      print("Firebase Authservice");
      // Thực hiện đăng nhập
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('⏰ FirebaseAuth timed out after 10s');
        },
      );;
      print("Xuong duoc day");
      print(credential);
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
          .select('role_name, store_id')
          .eq('email', userEmail)
          .single();

      // 3) Kiểm tra lỗi
      print("res:${res}");
      print('⚠️ [Auth] Login success user for email=$userEmail');
      final String roleName  = res['role_name'] as String;
      final int? storeId = res['store_id'] as int?;
      print('✅ roleName=$roleName, store_id=$storeId');
      return AuthResult(
        uid: user.uid,
        email: user.email!,
        roleName: roleName,
        storeId: storeId,        // ← trả về storeId luôn
      );
    }
    on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e, st) {
      print('❌ Lỗi không phải AuthException: $e');
      print(st);
      rethrow;
    }


  }
}
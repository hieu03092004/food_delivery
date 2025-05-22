import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../model/shipper_model/profile_model.dart';

class ProfileService{
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<ProfileModel> getProfile(int userId) async {
    final data = await _supabase
        .from('account')
        .select('account_id, full_name, email, avatar_url, address, status, store_id, latitude, longitude,phone_number,gender,date_of_birth')
        .eq('account_id', userId)
        .single();
    print('Data:$data');
    return ProfileModel.fromJson(data);
  }
  Future<bool> updateProfileField({
    required int accountId,
    required String name,
    required dynamic value,
  }) async {
    try {
      final response = await _supabase
          .from('account')
          .update({name: value})
          .eq('account_id', accountId)
          .select()
          .single();
      print('✅ Đã cập nhật $name thành $value cho account_id $accountId');
      return true;
    } catch (e) {
      print('❌ Lỗi khi cập nhật profile: $e');
      return false;
    }
  }
  Future<String> updateImage({
    required File image,
    required String bucket,
    required String path,
    bool upsert=false,
  }) async {

    await _supabase.storage.from(bucket).update(
      path,
      image,
      fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
    );

    final String publicUrl = _supabase
        .storage
        .from(bucket)
        .getPublicUrl(path);

    return "$publicUrl?ts=${DateTime.now().millisecond}";

  }
  Future<String?> uploadAvatar({
    required int userId,
    required File image,
  }) async {
    try {
      final String path = "users/user_${userId}.jpg";

      // Upload ảnh lên Supabase Storage
      final String publicUrl = await updateImage(
        image: image,
        bucket: 'images',
        path: path,
        upsert: true,
      );

      print('🌐 Public URL: $publicUrl');

      // Cập nhật avatar_url vào bảng account
      final response = await _supabase
          .from('account')
          .update({'avatar_url': publicUrl})
          .eq('account_id', userId)
          .select()
          .single();

      print('✅ Cập nhật avatar_url thành công');
      return publicUrl;
    } catch (e) {
      print('❌ Lỗi trong uploadAvatar: $e');
      return null;
    }
  }


}
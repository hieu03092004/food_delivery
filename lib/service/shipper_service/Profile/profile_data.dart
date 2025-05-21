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
}
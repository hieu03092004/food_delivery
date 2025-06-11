import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileModel {
  final int accountId;
  final String? fullName;
  final String email;
  final String? avatarUrl;
  final String? address;
  final String? status;
  final int? storeId;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? gender;
  final DateTime? dateOfBirth;

  ProfileModel({
    required this.accountId,
    this.fullName,
    required this.email,
    this.avatarUrl,
    this.address,
    this.status,
    this.storeId,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      accountId: json['account_id'],
      fullName: json['full_name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      address: json['address'],
      status: json['status'],
      storeId: json['store_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'address': address,
      'status': status,
      'store_id': storeId,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    int? accountId,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? address,
    String? status,
    int? storeId,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return ProfileModel(
      accountId: accountId ?? this.accountId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      status: status ?? this.status,
      storeId: storeId ?? this.storeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

class ProfileSnapshot {
  static final _supabase = Supabase.instance.client;

  static Future<ProfileModel> getProfile(int userId) async {
    final data =
        await _supabase
            .from('account')
            .select(
              'account_id, full_name, email, avatar_url, address, status, store_id, latitude, longitude,phone_number,gender,date_of_birth',
            )
            .eq('account_id', userId)
            .single();
    print('Data:$data');
    return ProfileModel.fromJson(data);
  }

  static Future<bool> updateProfileField({
    required int accountId,
    required String name,
    required dynamic value,
  }) async {
    try {
      final response =
          await _supabase
              .from('account')
              .update({name: value})
              .eq('account_id', accountId)
              .select()
              .single();
      print('Đã cập nhật $name thành $value cho account_id $accountId');
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật profile: $e');
      return false;
    }
  }

  static Future<String> updateImage({
    required File image,
    required String bucket,
    required String path,
    bool upsert = false,
  }) async {
    await _supabase.storage
        .from(bucket)
        .update(
          path,
          image,
          fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
        );

    final String publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);

    return "$publicUrl?ts=${DateTime.now().millisecond}";
  }

  static Future<String?> uploadAvatar({
    required int userId,
    required File image,
  }) async {
    try {
      final String path = "users/user_${userId}.jpg";

      final String publicUrl = await updateImage(
        image: image,
        bucket: 'images',
        path: path,
        upsert: true,
      );

      print('Public URL: $publicUrl');
      final response =
          await _supabase
              .from('account')
              .update({'avatar_url': publicUrl})
              .eq('account_id', userId)
              .select()
              .single();

      print('Cập nhật avatar_url thành công');
      return publicUrl;
    } catch (e) {
      print('Lỗi trong uploadAvatar: $e');
      return null;
    }
  }

  static Future<Map<int, ProfileModel>> getProfiles() async {
    final data = await _supabase.from('account').select().order('account_id');

    final Map<int, ProfileModel> profiles = {};
    for (var item in data) {
      final profile = ProfileModel.fromJson(item);
      profiles[profile.accountId] = profile;
    }
    return profiles;
  }

  static Stream<List<ProfileModel>> getProfileStream() {
    return _supabase
        .from('account')
        .stream(primaryKey: ['account_id'])
        .map(
          (data) => data.map((json) => ProfileModel.fromJson(json)).toList(),
        );
  }

  static void unsubscribeProfileChanges() {
    _supabase.channel('public:account').unsubscribe();
  }
}

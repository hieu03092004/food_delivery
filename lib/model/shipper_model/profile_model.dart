import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileModel {
  final int id;
  final int accountId;
  final String name;
  final String? phoneNumber;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.accountId,
    required this.name,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['account_id'],
      accountId: json['account_id'],
      name: json['full_name'] ?? '',
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'full_name': name,
      'phone_number': phoneNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }

  ProfileModel copyWith({
    int? id,
    int? accountId,
    String? name,
    String? phoneNumber,
    String? gender,
    DateTime? dateOfBirth,
    String? avatarUrl,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  static Future<ProfileModel?> getProfile(int accountId) async {
    try {
      final response =
          await Supabase.instance.client
              .from('account')
              .select()
              .eq('account_id', accountId)
              .single();
      return ProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateName(int accountId, String newName) async {
    try {
      await Supabase.instance.client
          .from('account')
          .update({'full_name': newName})
          .eq('account_id', accountId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateProfileField(
    int accountId,
    String fieldName,
    dynamic value,
  ) async {
    try {
      await Supabase.instance.client
          .from('account')
          .update({fieldName: value})
          .eq('account_id', accountId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> uploadAvatar(int accountId, File image) async {
    try {
      final String fileName = 'avatar_$accountId.jpg';
    

      // Upload image to storage
      await Supabase.instance.client.storage
          .from('images')
          .upload(fileName, image, fileOptions: FileOptions(upsert: true));

      // Get public URL
      final String avatarUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      // Update profile with new avatar URL
      await Supabase.instance.client
          .from('account')
          .update({'avatar_url': avatarUrl})
          .eq('account_id', accountId);
    } catch (e) {
      rethrow;
    }
  }
}

class ProfileSnapshot {
  static final _supabase = Supabase.instance.client;

  static Future<ProfileModel> getProfile(int userId) async {
    final data =
        await _supabase
            .from('account')
            .select(
              'account_id, full_name, avatar_url, address, status, store_id, latitude, longitude,phone_number,gender,date_of_birth',
            )
            .eq('account_id', userId)
            .single();
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
      return true;
    } catch (e) {
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

      final response =
          await _supabase
              .from('account')
              .update({'avatar_url': publicUrl})
              .eq('account_id', userId)
              .select()
              .single();

      return publicUrl;
    } catch (e) {
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

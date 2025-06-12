import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_delivery/model/shipper_model/profile_model.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';

class ProfileService extends GetxController {
  final _profile = Rxn<ProfileModel>();
  final _isLoading = false.obs;
  final _error = ''.obs;
  final _hasDataChanged = false.obs;
  final _name = ''.obs;

  ProfileModel? get profile => _profile.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasDataChanged => _hasDataChanged.value;
  String get name => _name.value;

  @override
  void onInit() {
    super.onInit();
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn) {
      fetchProfile(authService.accountId.value);
    }
  }

  Future<void> fetchProfile(int accountId) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      final profile = await ProfileModel.getProfile(accountId);
      if (profile != null) {
        _profile.value = profile;
        _name.value = profile.name;
      } else {
        _error.value = 'Không thể tải thông tin profile';
      }
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateName(int accountId, String newName) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      await ProfileModel.updateName(accountId, newName);
      _name.value = newName;
      _hasDataChanged.value = true;
      await fetchProfile(accountId);
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfileField({
    required int accountId,
    required String name,
    required dynamic value,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      await ProfileModel.updateProfileField(accountId, name, value);
      _hasDataChanged.value = true;
      await fetchProfile(accountId);
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImage(int accountId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _isLoading.value = true;
        _error.value = '';

        final File imageFile = File(image.path);
        await ProfileModel.uploadAvatar(accountId, imageFile);
        _hasDataChanged.value = true;
        await fetchProfile(accountId);
      }
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  ImageProvider getAvatarProvider() {
    if (_profile.value?.avatarUrl != null &&
        _profile.value!.avatarUrl!.isNotEmpty) {
      return NetworkImage(_profile.value!.avatarUrl!);
    }
    return const AssetImage('assets/images/default_avatar.png');
  }

  @override
  void onClose() {
    _profile.close();
    _hasDataChanged.close();
    super.onClose();
  }
}

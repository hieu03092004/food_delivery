import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_delivery/model/shipper_model/profile_model.dart';
import 'package:food_delivery/service/shipper_service/Accounts/account_service.dart';

class ProfileService extends GetxController {
  final _profile = Rxn<ProfileModel>();
  final _isLoading = false.obs;
  final _error = ''.obs;
  final _hasDataChanged = false.obs;
  final _name = ''.obs;
  final uploadedImage = Rx<File?>(null);

  final AccountService _accountService = Get.find<AccountService>();

  ProfileModel? get profile => _profile.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasDataChanged => _hasDataChanged.value;
  String get name => _name.value;

  @override
  void onInit() {
    super.onInit();
    _hasDataChanged.value = false;
  }

  Future<void> fetchProfile(int userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      final profile = await ProfileSnapshot.getProfile(userId);
      _profile.value = profile;
      _name.value = profile?.fullName ?? '';
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateName(int userId, String newName) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      await ProfileSnapshot.updateProfileField(
        accountId: userId,
        name: 'full_name',
        value: newName,
      );
      _name.value = newName;
      _hasDataChanged.value = true;

      // Cập nhật AccountService
      _accountService.updateName(newName);
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
      await ProfileSnapshot.updateProfileField(
        accountId: accountId,
        name: name,
        value: value,
      );
      await fetchProfile(accountId);
      _hasDataChanged.value = true;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImage(int userId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _isLoading.value = true;
        _error.value = '';
        final File imageFile = File(image.path);
        uploadedImage.value = imageFile;
        final String? avatarUrl = await ProfileSnapshot.uploadAvatar(
          userId: userId,
          image: imageFile,
        );
        if (avatarUrl != null) {
          if (profile != null) {
            _profile.value = profile!.copyWith(avatarUrl: avatarUrl);
          }
          _hasDataChanged.value = true;

          // Cập nhật AccountService
          _accountService.updateAvatar(avatarUrl);
        }
      }
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  ImageProvider getAvatarProvider() {
    if (uploadedImage.value != null) {
      return FileImage(uploadedImage.value!);
    }
    final currentProfile = profile;
    if (currentProfile?.avatarUrl != null &&
        currentProfile!.avatarUrl!.isNotEmpty) {
      return NetworkImage(currentProfile.avatarUrl!);
    }
    return const AssetImage('images/avatar.jpg');
  }

  @override
  void onClose() {
    _profile.close();
    _hasDataChanged.close();
    uploadedImage.close();
    super.onClose();
  }
}

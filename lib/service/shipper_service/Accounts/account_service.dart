import 'package:get/get.dart';
import 'package:food_delivery/model/shipper_model/account_model.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';

class AccountService extends GetxController {
  final account = Rx<Account?>(null);
  final isLoading = false.obs;
  final error = ''.obs;
  final hasNameChanged = false.obs;
  final hasAvatarChanged = false.obs;
  final AccountRepository _repository = AccountRepository();

  Future<void> fetchAccount(int accountId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final fetchedAccount = await _repository.fetchAccount(accountId);
      account.value = fetchedAccount;
      isLoading.value = false;
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  // Update account data
  Future<void> updateAccount(
    int accountId, {
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final Map<String, dynamic> updateData = {};
      if (fullName != null) updateData['full_name'] = fullName;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      if (updateData.isEmpty) 
        return;

      await _repository.updateAccount(accountId, updateData);

      // Refresh account data after update
      await fetchAccount(accountId);
    } catch (e) {
      error.value = 'Lỗi khi cập nhật thông tin: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void updateName(String newName) {
    if (account.value != null) {
      account.value = Account(
        fullName: newName,
        avatarUrl: account.value!.avatarUrl,
      );
      hasNameChanged.value = true;
    }
  }

  void updateAvatar(String newAvatarUrl) {
    if (account.value != null) {
      account.value = Account(
        fullName: account.value!.fullName,
        avatarUrl: newAvatarUrl,
      );
      hasAvatarChanged.value = true;
    }
  }

  // Sign out function - only handle logic
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Get AuthService instance
      final authService = Get.find<AuthService>();

      // Call signOut from AuthService
      await authService.signOut();

      // Clear local data
      account.value = null;
      hasNameChanged.value = false;
      hasAvatarChanged.value = false;
    } catch (e) {
      error.value = 'Lỗi khi đăng xuất: $e';
      rethrow; // Re-throw to let UI handle the error
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    account.close();
    hasNameChanged.close();
    hasAvatarChanged.close();
    super.onClose();
  }
}

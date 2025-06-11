import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/profile/profile_information/profile.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/income/inComePage.dart';
import 'package:food_delivery/service/shipper_service/Accounts/account_service.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/pages/customer_pages/bottom_customer_nav.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({Key? key}) : super(key: key);

  static const _primaryColor = Color(0xFFEF2B39);
  static const _textColor = Colors.black87;

  // Show sign out confirmation dialog
  Future<bool?> _showSignOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận đăng xuất',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Handle sign out process
  Future<void> _handleSignOut(BuildContext context) async {
    final accountService = Get.find<AccountService>();
    final bool? confirm = await _showSignOutDialog(context);

    if (confirm == true) {
      try {
        await accountService.signOut();
        // Navigate to home page after successful sign out
        Get.offAll(() => const BottomCustomerNav());
      } catch (e) {
        // Show error message if sign out fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize AccountService if not registered
    if (!Get.isRegistered<AccountService>()) {
      Get.put(AccountService(), permanent: true);
    }

    final accountService = Get.find<AccountService>();
    final authService = Get.find<AuthService>();

    // Fetch account data when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.isLoggedIn) {
        accountService.fetchAccount(authService.accountId.value);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tài khoản',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (!authService.isLoggedIn) {
          return const Center(
            child: Text('Vui lòng đăng nhập để xem thông tin tài khoản'),
          );
        }

        if (accountService.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (accountService.error.isNotEmpty) {
          return Center(child: Text(accountService.error.value));
        }

        final account = accountService.account.value;
        if (account == null) {
          return const Center(
            child: Text('Không tìm thấy thông tin tài khoản'),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // ===== Header user =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Wrap avatar in Obx to only reload this component
                  Obx(
                    () => CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          accountService.hasAvatarChanged.value
                              ? NetworkImage(
                                accountService.account.value!.avatarUrl!,
                              )
                              : (account.avatarUrl != null &&
                                      account.avatarUrl!.isNotEmpty
                                  ? NetworkImage(account.avatarUrl!)
                                  : const AssetImage('images/avatar.jpg')
                                      as ImageProvider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wrap name in Obx to only reload this component
                        Obx(
                          () => Text(
                            accountService.account.value?.fullName ??
                                account.fullName,
                            style: const TextStyle(
                              color: _textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => _navigate('Hồ sơ cá nhân'),
                          child: const Text(
                            'Chỉnh sửa hồ sơ',
                            style: TextStyle(
                              fontSize: 14,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // ===== Các mục menu =====
            _buildMenuItem(
              icon: Icons.person_outline,
              label: 'Hồ sơ cá nhân',
              onTap: () => _navigate('Hồ sơ cá nhân'),
            ),
            const Divider(height: 1),

            _buildMenuItem(
              icon: Icons.bar_chart_outlined,
              label: 'Thu nhập',
              onTap: () => _navigate('Thu nhập'),
            ),
            const Divider(height: 1),

            _buildMenuItem(
              icon: Icons.logout,
              label: 'Đăng xuất',
              onTap: () => _handleSignOut(context),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _navigate(String screenName) async {
    Widget page;
    switch (screenName) {
      case 'Thu nhập':
        page = IncomePage();
        break;
      case 'Hồ sơ cá nhân':
        page = const Profile();
        break;
      default:
        page = Scaffold(
          appBar: AppBar(title: Text(screenName)),
          body: Center(child: Text('Trang $screenName đang được xây dựng')),
        );
    }

    await Get.to(() => page);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor, size: 24),
      title: Text(
        label,
        style: const TextStyle(color: _textColor, fontSize: 15),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      horizontalTitleGap: 20,
      onTap: onTap,
    );
  }
}

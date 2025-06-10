import 'package:flutter/material.dart';
import 'package:food_delivery/widget/default_appBar.dart';
import 'package:get/get.dart';

import '../../../service/auth_servicae/AuthService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Thêm biến account (cần được khởi tạo từ service hoặc state management)
  final account = AccountModel(fullName: "Tên người dùng"); // Tạm thời

  static const Color _textColor = Colors.black87; // Định nghĩa màu text

  Future<void> _navigate(BuildContext context, String screenName) async {
    if (screenName == 'Đăng xuất') {
      // Xử lý đăng xuất
      await _handleLogout(context);
      return;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Hiển thị dialog xác nhận
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Đăng xuất',
              ),
            ),
          ],
        );
      },
    );

    // Nếu user xác nhận đăng xuất
    if (shouldLogout == true) {
      try {
        // Hiển thị loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Gọi signOut từ AuthService
        final authService = Get.find<AuthService>();
        await authService.signOut();

        // Đóng loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng xuất thành công'),
            backgroundColor: Colors.green,
          ),
        );

      } catch (e) {
        // Đóng loading dialog nếu có lỗi
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Hiển thị lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      horizontalTitleGap: 20,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Tài khoản", showCartIcon: false,),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ===== Header user =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('images/avatar.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.fullName,
                        style: const TextStyle(
                          color: _textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _navigate(context, 'Hồ sơ cá nhân'),
                        child: const Text(
                          'Chỉnh sửa hồ sơ',
                          style: TextStyle(
                            fontSize: 14,
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
            onTap: () => _navigate(context, 'Hồ sơ cá nhân'),
          ),
          const Divider(height: 1),

          _buildMenuItem(
            icon: Icons.logout,
            label: 'Đăng xuất',
            onTap: () => _navigate(context, 'Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

// Model class tạm thời - bạn cần thay thế bằng model thực tế
class AccountModel {
  final String fullName;

  AccountModel({required this.fullName});
}
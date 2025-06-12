
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';

import 'package:food_delivery/model/customer_model/account_model.dart';
import 'package:food_delivery/widget/default_appBar.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = Get.find<AuthService>();
  Account? _account;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final id = _auth.accountId.value;
    if (id == 0) {
      // chưa login → có thể điều hướng đến login
      setState(() => _loading = false);
      return;
    }
    try {
      final acc = await AccountSnapshot.getAccount(id);
      setState(() {
        _account = acc;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      Get.snackbar('Lỗi', 'Không thể tải hồ sơ: $e');
    }
  }

  Future<void> _navigate(BuildContext ctx, String screen) async {
    if (screen == 'Hồ sơ cá nhân') {
      if (_account != null) {
        // await Get.to(() => ProfiledetailPage(account: _account!));
        // khi quay về có thể reload
        _loadAccount();
      }
    } else if (screen == 'Đăng xuất') {
      await _handleLogout(ctx);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (confirm == true) {
      showDialog(
        context: context, barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await _auth.signOut();
        Navigator.pop(context); // close loading
        Get.offAllNamed('/login');
      } catch (e) {
        Navigator.pop(context);
        Get.snackbar('Lỗi', 'Đăng xuất thất bại: $e', backgroundColor: Colors.red);
      }
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const CommonAppBar(title: "Tài khoản", showCartIcon: false),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          if (_account != null) _buildHeader(_account!),
          const Divider(),
          _buildMenuItem(
            icon: Icons.person_outline,
            label: 'Hồ sơ cá nhân',
            onTap: () {

            },
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.logout,
            label: 'Đăng xuất',
            onTap: () => _navigate(context, 'Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Account acc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage:
            acc.avatarUrl.isNotEmpty ? NetworkImage(acc.avatarUrl) : null,
            child: acc.avatarUrl.isEmpty ? const Icon(Icons.person, size: 32) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc.fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),

                const SizedBox(height: 4),
                Text(acc.phoneNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

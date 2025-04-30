import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'inComePage.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  void _navigate(BuildContext context, String screenName) {
    Widget page;

    switch (screenName) {
      case 'Thu nhập':
        page = const IncomePage();
        break;
      default:
        page = Scaffold(
          appBar: AppBar(title: Text(screenName)),
          body: Center(child: Text('Trang $screenName đang được xây dựng')),
        );
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Tài khoản',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Profile Header với căn giữa dọc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/avatar.png'), // chỉnh đường dẫn avatar
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Thành Hiếu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _navigate(context, 'Chỉnh sửa hồ sơ'),
                        child: const Text(
                          'Chỉnh sửa hồ sơ',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Hồ sơ cá nhân
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Hồ sơ cá nhân'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigate(context, 'Hồ sơ cá nhân'),
          ),
          const Divider(),

          // Thu nhập
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Thu nhập'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigate(context, 'Thu nhập'),
          ),
          const Divider(),

          // Đơn hàng
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Đơn hàng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigate(context, 'Đơn hàng'),
          ),
          const Divider(),

          // Hỗ trợ
          ListTile(
            leading: const Icon(Icons.headset_mic_outlined),
            title: const Text('Hỗ trợ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigate(context, 'Hỗ trợ'),
          ),
          const Divider(),

          // Đăng xuất
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigate(context, 'Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/profile/profile_information/profile.dart';
import '../../../model/shipper_model/account_model.dart';
import '../../authentication/authenticaion_state/authenticationCubit.dart';
import 'income/inComePage.dart';
class AccountsPage extends StatefulWidget {
  const AccountsPage({Key? key}) : super(key: key);

  static const _primaryColor = Color(0xFFEF2B39);
  static const _textColor = Colors.black87;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  late Future<Account?> _accountFuture;
  int? _currentUid;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }
  Future<void> _navigate(BuildContext context, String screenName) async {
    Widget page;
    switch (screenName) {
      case 'Thu nhập':
        page = const IncomePage();
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

    // 🔥 SỬA LỖI: Chờ kết quả từ navigation
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    print('screenName: $screenName');
    print('result from navigation: $result');

    // Nếu trả về từ Profile page và có thay đổi, refresh data
    if (screenName == 'Hồ sơ cá nhân' && result == true) {
      print('🔄 Refreshing account data...');
      _refreshAccountData();
    }
  }

  void _loadAccountData() {
    final authState = context.read<AuthenticationCubit>().state;
    final int? uid = authState.user?.uid;
    if (uid != null) {
      _currentUid = uid;
      _accountFuture = AccountRepository().fetchAccount(uid);
    }
  }
  // Phương thức này sẽ được gọi khi quay về từ Profile page
  void _refreshAccountData() {
    if (_currentUid != null) {
      setState(() {
        _accountFuture = AccountRepository().fetchAccount(_currentUid!);
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    // Lấy uid từ state hoặc context của bạn
    final authState = context.watch<AuthenticationCubit>().state;
    final int? uid = authState.user?.uid;

    if (uid == null) {
      return const Center(child: Text('Chưa đăng nhập'));
    }

    return FutureBuilder<Account?>(
      future: _accountFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || snap.data == null) {
          return const Scaffold(
            body: Center(child: Text('Không tải được thông tin')),
          );
        }

        final account = snap.data!;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Tài khoản',
              style: TextStyle(
                color: AccountsPage._textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ===== Header user =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: account.avatarUrl != null && account.avatarUrl!.isNotEmpty
                          ? NetworkImage(account.avatarUrl!)
                          : const AssetImage('images/avatar.jpg') as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.fullName,
                            style: const TextStyle(
                              color: AccountsPage._textColor,
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
                                color: AccountsPage._primaryColor,
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
                icon: Icons.bar_chart_outlined,
                label: 'Thu nhập',
                onTap: () => _navigate(context, 'Thu nhập'),
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
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AccountsPage._primaryColor, size: 24),
      title: Text(
        label,
        style: const TextStyle(color: AccountsPage._textColor, fontSize: 15),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      horizontalTitleGap: 20,
      onTap: onTap,
    );
  }
}

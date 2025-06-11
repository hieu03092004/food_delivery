import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/profile/profile_information/editDateOfBirthPage.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/profile/profile_information/editGender.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/profile/profile_information/editPhoneNumber.dart';
import 'package:food_delivery/service/shipper_service/Profile/profile_service.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'editEmail.dart';
import 'editName.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  static const _primaryColor = Color(0xFFEF2B39);

  @override
  Widget build(BuildContext context) {
    // Initialize services if not registered
    if (!Get.isRegistered<ProfileService>()) {
      Get.put(ProfileService(), permanent: true);
    }

    final profileService = Get.find<ProfileService>();
    final authService = Get.find<AuthService>();

    // Fetch profile data when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.isLoggedIn) {
        profileService.fetchProfile(authService.accountId.value);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa trang cá nhân'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, profileService.hasDataChanged);
          },
        ),
      ),
      body: Column(
        children: [
          if (!authService.isLoggedIn)
            const Center(
              child: Text('Vui lòng đăng nhập để xem thông tin tài khoản'),
            )
          else if (profileService.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (profileService.error.isNotEmpty)
            Center(child: Text('Error: ${profileService.error}'))
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    // Avatar section with Obx
                    Obx(
                      () => Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profileService.getAvatarProvider(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed:
                            () => profileService.pickAndUploadImage(
                              authService.accountId.value,
                            ),
                        child: const Text(
                          'Thay đổi avatar',
                          style: TextStyle(color: _primaryColor),
                        ),
                      ),
                    ),
                    const Divider(),
                    // Profile Information
                    _buildSectionTitle('Thông tin tài khoản'),
                    // Name with Obx
                    Obx(
                      () => _buildInfoTile(
                        context,
                        'Tên',
                        profileService.name,
                        () => _navigateToEdit(
                          context,
                          'Tên',
                          authService.accountId.value,
                          profileService,
                        ),
                      ),
                    ),
                    const Divider(),
                    // Personal Information
                    _buildInfoTile(
                      context,
                      'Email',
                      profileService.profile?.email ?? '',
                      () => _navigateToEdit(
                        context,
                        'Email',
                        authService.accountId.value,
                        profileService,
                      ),
                    ),
                    _buildInfoTile(
                      context,
                      'Số điện thoại',
                      profileService.profile?.phoneNumber ?? '',
                      () => _navigateToEdit(
                        context,
                        'Số điện thoại',
                        authService.accountId.value,
                        profileService,
                      ),
                    ),
                    _buildInfoTile(
                      context,
                      'Giới tính',
                      profileService.profile?.gender == null
                          ? 'Chưa có'
                          : (profileService.profile!.gender == 'male'
                              ? 'Nam'
                              : 'Nữ'),
                      () => _navigateToEdit(
                        context,
                        'Giới tính',
                        authService.accountId.value,
                        profileService,
                      ),
                    ),
                    _buildInfoTile(
                      context,
                      'Ngày sinh',
                      profileService.profile?.dateOfBirth == null
                          ? ''
                          : profileService.profile!.dateOfBirth!
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                      () => _navigateToEdit(
                        context,
                        'Ngày sinh',
                        authService.accountId.value,
                        profileService,
                      ),
                    ),
                    const Divider(),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context, profileService.hasDataChanged);
                        },
                        child: const Text(
                          'Đóng',
                          style: TextStyle(color: _primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(width: 20),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    String label,
    int userId,
    ProfileService profileService,
  ) async {
    switch (label) {
      case 'Tên':
        final String? newName = await Navigator.push<String?>(
          context,
          MaterialPageRoute(builder: (_) => const EditNamePage()),
        );
        if (newName != null && newName.isNotEmpty) {
          await profileService.updateName(userId, newName);
        }
        break;

      case 'Email':
        final String? newEmail = await Navigator.push<String?>(
          context,
          MaterialPageRoute(builder: (_) => const EditEmailPage()),
        );
        if (newEmail != null && newEmail.isNotEmpty) {
          await profileService.updateProfileField(
            accountId: userId,
            name: 'email',
            value: newEmail,
          );
        }
        break;

      case 'Số điện thoại':
        final String? newPhone = await Navigator.push<String?>(
          context,
          MaterialPageRoute(builder: (_) => const EditPhonePage()),
        );
        if (newPhone != null && newPhone.isNotEmpty) {
          await profileService.updateProfileField(
            accountId: userId,
            name: 'phone_number',
            value: newPhone,
          );
        }
        break;

      case 'Giới tính':
        final String? newGender = await Navigator.push<String?>(
          context,
          MaterialPageRoute(builder: (_) => const EditGenderPage()),
        );
        if (newGender != null && newGender.isNotEmpty) {
          await profileService.updateProfileField(
            accountId: userId,
            name: 'gender',
            value: newGender,
          );
        }
        break;

      case 'Ngày sinh':
        final DateTime? newDob = await Navigator.push<DateTime?>(
          context,
          MaterialPageRoute(builder: (_) => const EditDateOfBirthPage()),
        );
        if (newDob != null) {
          await profileService.updateProfileField(
            accountId: userId,
            name: 'date_of_birth',
            value: newDob.toIso8601String(),
          );
        }
        break;

      default:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  appBar: AppBar(title: Text(label)),
                  body: Center(child: Text('Chưa có trang cho "$label"')),
                ),
          ),
        );
    }
  }
}

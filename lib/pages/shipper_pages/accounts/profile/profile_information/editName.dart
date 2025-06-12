import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_delivery/service/shipper_service/Profile/profile_service.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';

class EditNamePage extends StatelessWidget {
  const EditNamePage({super.key});

  static const _primaryColor = Color(0xFFEF2B39);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final profileService = Get.find<ProfileService>();

    // Set initial value
    _nameController.text = profileService.profile?.name ?? '';

    void _saveName() async {
      final newName = _nameController.text.trim();
      if (newName.isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Tên không được để trống',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Update name using ProfileService
      await profileService.updateName(
        Get.find<AuthService>().accountId.value,
        newName,
      );

      Get.back(result: newName); // Return the new name
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thay đổi tên"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sử dụng tên thật của bạn giúp quá trình xác thực diễn ra dễ dàng hơn.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

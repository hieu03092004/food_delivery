import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';

class HomePages extends StatelessWidget {
  const HomePages({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Trang chủ của shipper"),
            SizedBox(height: 20),
            Obx(
              () => Text(
                "User ID: ${authService.accountId.value}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

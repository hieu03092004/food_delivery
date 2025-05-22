import 'package:flutter/material.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:get/get.dart';
class HomePages extends StatelessWidget {
  const HomePages({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final account_id = auth.accountId.value;
    print(account_id);

    return  Scaffold(
      body: Center(
        child: Text("Trang chủ của shipper"),
      ),
    );
  }
}

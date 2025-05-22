import 'package:flutter/material.dart';
import 'package:food_delivery/config/database.dart';
import 'package:food_delivery/pages/admin_pages/Bottom_nav_admin.dart';
import 'package:food_delivery/pages/authentication/PageAuthUser.dart';
import 'package:food_delivery/pages/customer_pages/bottom_customer_nav.dart';
import 'package:food_delivery/pages/customer_pages/cart/cart_page.dart';
import 'package:food_delivery/pages/shipper_pages/Bottom_nav_shipper.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.init();
  // Put services vào GetX
  Get.put(AuthService(), permanent: true);
  Get.put(CartService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      // Không dùng initialRoute, dùng Obx để chọn home
      home: Obx(() {
        // Khi AuthService đã xử lý xong onAuthState,
        // nếu đã login thì AuthService._handleSignIn đã Get.offAll tương ứng,
        // nhưng sau hot-reload hoặc lần đầu null session, ta vẫn show BottomCustomerNav
        if (auth.isLoggedIn) {
          print("role name main: ${auth.roleName.value}");
          // Chọn màn hình theo role
          switch (auth.roleName.value) {
            case 'admin':
              return const BottomNavAdmin();
            case 'shipper':
              return const BottomNavShipper();
            default:
              return const BottomCustomerNav();
          }
        } else {
          // Chưa login → home guest
          return const BottomCustomerNav();
        }
      }),
      // Khai báo routes (nếu cần navigation by name)
      getPages: [
        GetPage(name: '/cart', page: () {
          final id = Get.find<AuthService>().accountId.value;
          return id != 0
              ? CartPage(accountId: id)
              : const PageAuthUser();
        }),
        GetPage(name: '/login', page: () => const PageAuthUser()),
        // ... thêm các route khác nếu cần
      ],
    );
  }
}

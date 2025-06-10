import 'package:flutter/material.dart';
import 'package:food_delivery/config/database.dart';
import 'package:food_delivery/pages/customer_pages/cart/cart_page.dart';
import 'package:food_delivery/pages/customer_pages/home/home_page.dart';
import 'package:food_delivery/pages/customer_pages/profile/profile_page.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:get/get.dart';

class BottomCustomerNav extends StatefulWidget {
  const BottomCustomerNav({super.key});

  @override
  State<BottomCustomerNav> createState() => _BottomCustomerNavState();
}

class _BottomCustomerNavState extends State<BottomCustomerNav> {
  final auth = Get.find<AuthService>();
  final cartService = Get.find<CartService>();
  int currentTabIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    Database.init();

    pages = [
      const HomePage(),
      const SizedBox.shrink(), // placeholder for CartPage
      // const NotificationsPage(),
      const ProfilePage(), // placeholder for ProfilePage
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthService>(
        builder: (_) {
          final isLoggedIn = auth.isLoggedIn;
          if (currentTabIndex == 1 && isLoggedIn) {
            return CartPage(accountId: auth.accountId.value);
          } else if (currentTabIndex == 3 && isLoggedIn) {
            return const ProfilePage();
          }
          return pages[currentTabIndex];
        },
      ),
      bottomNavigationBar: Obx(() {
        final itemCount = cartService.distinctCount.value;
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentTabIndex,
          selectedItemColor: const Color(0xffef2b39),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_bag),

                ],
              ),
              label: 'Đơn hàng',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Thông báo',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Tài khoản',
            ),
          ],
          onTap: (value) {
            final isLoggedInTap = auth.isLoggedIn;
            if ((value == 1 || value == 3) && !isLoggedInTap) {
              Get.toNamed('/login');
            } else {
              setState(() {
                currentTabIndex = value;
              });
            }
          },
        );
      }),
    );
  }
}

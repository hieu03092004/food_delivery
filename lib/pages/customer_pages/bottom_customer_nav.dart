import 'package:flutter/material.dart';
import 'package:food_delivery/config/database.dart';
import 'package:food_delivery/pages/customer_pages/cart/cart_page.dart';
import 'package:food_delivery/pages/customer_pages/home/home_page.dart';
import 'package:food_delivery/pages/customer_pages/profile/profile_page.dart';
import 'package:food_delivery/pages/shipper_pages/Notifications/notifications.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:food_delivery/service/shipper_service/Notifications/notification_service.dart';
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

    // Initialize NotificationService if not already registered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<NotificationService>()) {
        final userId = auth.accountId.value;
        if (userId != 0) {
          Get.put(NotificationService(userId), permanent: true);
        }
      }
    });

    pages = [
      const HomePage(),
      const SizedBox.shrink(), // placeholder for CartPage
      NotificationsPage(),
      const ProfilePage(),
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
        final unreadCount =
            Get.isRegistered<NotificationService>()
                ? Get.find<NotificationService>().unreadCount.value
                : 0;

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
                  if (itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xffef2b39),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xffef2b39),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
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

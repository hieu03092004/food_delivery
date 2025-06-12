import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/accounts_page.dart';
import 'package:food_delivery/pages/shipper_pages/orders/orders_shipper_pages.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/shipper_service/Order/Order_service.dart';
import 'package:food_delivery/service/shipper_service/Notifications/notification_service.dart';
import 'Notifications/notifications.dart';

class BottomNavShipper extends StatelessWidget {
  const BottomNavShipper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final currentTabIndex = 0.obs;

    // Khởi tạo OrderService nếu chưa được đăng ký
    if (!Get.isRegistered<OrderService>()) {
      Get.put<OrderService>(OrderService(), permanent: true);
    }

    // Fetch số notification chưa đọc ngay sau build first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Chỉ xử lý notification khi đã đăng nhập
      if (authService.isLoggedIn) {
        final userId = authService.accountId.value;
        if (!Get.isRegistered<NotificationService>()) {
         
          Get.put(NotificationService(userId), permanent: true);
        }
        // Fetch unread count
        await Get.find<NotificationService>().fetchUnreadCount();
      }
    });

    final pages = [OrdersShipperPages(), NotificationsPage(), AccountsPage()];

    return Scaffold(
      body: Obx(() => pages[currentTabIndex.value]),
      bottomNavigationBar: Obx(() {
        // Chỉ hiển thị unread count khi đã đăng nhập và có NotificationService
        final unreadCount =
            authService.isLoggedIn && Get.isRegistered<NotificationService>()
                ? Get.find<NotificationService>().unreadCount.value
                : 0;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentTabIndex.value,
          selectedItemColor: const Color(0xffef2b39),
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications),
                  if (unreadCount > 0)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
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
          onTap: (index) async {
            currentTabIndex.value = index;

            // Khi bấm vào tab Thông báo (index 1)
            if (index == 1 &&
                authService.isLoggedIn &&
                Get.isRegistered<NotificationService>()) {
              final notificationService = Get.find<NotificationService>();
              // Theo yêu cầu mặc định đánh dấu "Hôm nay"
              await notificationService.markReadByFilter('today');
              await notificationService.fetchByFilter('today');
              await notificationService.fetchUnreadCount();
            }
          },
        );
      }),
    );
  }
}

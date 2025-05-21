import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/accounts_page.dart';
import 'package:food_delivery/pages/shipper_pages/home/home_pages.dart';
import 'package:food_delivery/pages/shipper_pages/orders/orders_shipper_pages.dart';

import '../../config/database.dart';
import '../../model/shipper_model/Notification_model.dart';
import 'Notifications/notifications.dart';

class BottomNavShipper extends StatefulWidget {
  const BottomNavShipper({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNavShipper> {
  late final List<Widget> pages;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePages(),
      OrdersShipperPages(),
      NotificationsPage(),
      AccountsPage(),
    ];

    // Fetch số notification chưa đọc ngay sau build first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy số unread từ provider
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: pages[currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTabIndex,
        selectedItemColor: const Color(0xffef2b39),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications),
                if (unread > 0)
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
                          minWidth: 16, minHeight: 16
                      ),
                      child: Text(
                        '$unread',
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
          setState(() => currentTabIndex = index);

          // Khi bấm vào tab Thông báo (index 2)
          if (index == 2) {
            final prov = context.read<NotificationProvider>();
            // Theo yêu cầu mặc định đánh dấu “Hôm nay”
            await prov.markReadByFilter('today');
            await prov.fetchByFilter('today');
            await prov.fetchUnreadCount();
          }
        },
      ),
    );
  }
}
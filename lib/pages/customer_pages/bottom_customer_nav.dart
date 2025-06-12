import 'package:flutter/material.dart';
import 'package:food_delivery/config/database.dart';
import 'package:food_delivery/model/customer_model/order_model.dart';

import 'package:food_delivery/pages/customer_pages/cart/cart_page.dart';
import 'package:food_delivery/pages/customer_pages/home/home_page.dart';
import 'package:food_delivery/pages/customer_pages/orderList_page.dart';
import 'package:food_delivery/pages/customer_pages/profile/profile_page.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';

import 'package:food_delivery/service/customer_service/controller_cart.dart';
import 'package:food_delivery/service/customer_service/controller_order.dart';
import 'package:get/get.dart';

class BottomCustomerNav extends StatefulWidget {
  const BottomCustomerNav({Key? key}) : super(key: key);

  @override
  _BottomCustomerNavState createState() => _BottomCustomerNavState();
}

class _BottomCustomerNavState extends State<BottomCustomerNav> {
  final auth = Get.find<AuthService>();



  int currentTabIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(),            // Trang chủ
      OrderListPage(),       // Đơn hàng
      ProfilePage(),         // Tài khoản
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
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
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Đơn hàng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        onTap: (index) {
          // Nếu cần bắt login trước khi vào "Đơn hàng" hoặc "Tài khoản"
          if ((index == 1 || index == 2) && !auth.isLoggedIn) {
            Get.toNamed('/login');
            return;
          }
          setState(() => currentTabIndex = index);
        },
      ),
    );
  }
}

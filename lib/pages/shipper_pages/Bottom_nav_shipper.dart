import 'package:flutter/material.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/accounts_page.dart';
import 'package:food_delivery/pages/shipper_pages/home/home_pages.dart';
import 'package:food_delivery/pages/shipper_pages/orders/orders_shipper_pages.dart';

import '../../config/database.dart';
import 'Notifications/notifications.dart';

class BottomNavShipper extends StatefulWidget {
  const BottomNavShipper({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNavShipper> {
  late List<Widget>pages;
  late HomePages HomePage;
  late OrdersShipperPages ordersPage;
  late NotificationsPage notificationsPage;
  late AccountsPage accountsPage;
  int currentTabIndex=0;




  @override
  void initState(){
    // TODO: implement initState
    HomePage=HomePages();
    ordersPage=OrdersShipperPages();
    notificationsPage=NotificationsPage();
    accountsPage=AccountsPage();
    pages=[HomePage,ordersPage,notificationsPage,accountsPage];
    super.initState();
    fetchData();
  }
  Future<void> fetchData() async {
    await Database.fetchFruits();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentTabIndex],
      // Bật nếu bạn có danh sách pages
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTabIndex,
        selectedItemColor: Color(0xffef2b39),
        unselectedItemColor: Colors.grey,

        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        onTap: (value) {
          setState(() {
            currentTabIndex = value;
          });
        },
      ),
    );
  }
}

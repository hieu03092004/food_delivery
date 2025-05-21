import 'package:flutter/material.dart';
import 'package:food_delivery/pages/customer_pages/home/home_page.dart';

import '../../config/database.dart';
class BottomCustomerNav extends StatefulWidget {
  const BottomCustomerNav({super.key});

  @override
  State<BottomCustomerNav> createState() => _BottomCustomerNavState();
}

class _BottomCustomerNavState extends State<BottomCustomerNav> {
  late List<Widget>pages;
  late HomePages HomePage;
  int currentTabIndex=0;
  @override
  void initState(){
    // TODO: implement initState
    HomePage=HomePages();
    pages=[HomePage];
    super.initState();
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

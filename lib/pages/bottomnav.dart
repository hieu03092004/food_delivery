import 'package:flutter/material.dart';
import 'package:food_delivery/pages/order.dart';
import 'package:food_delivery/pages/profile.dart';
import 'package:food_delivery/pages/wallet.dart';

import 'home.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget>pages;
  late Home HomePage;
  late Order order;
  late Wallet wallet;
  late Profile profile;
  int currentTabIndex=0;


  // Nếu bạn có các trang tương ứng với mỗi mục:
  // final List<Widget> _pages = [
  //   HomePage(),
  //   SmsPage(),
  //   PhonePage(),
  // ];
  @override
  void initState() {
    // TODO: implement initState
    HomePage=Home();
    order=Order();
    wallet=Wallet();
    profile=Profile();
    pages=[HomePage,order,wallet,profile];
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
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Thanh Toán',
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

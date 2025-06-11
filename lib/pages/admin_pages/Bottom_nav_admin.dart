import 'package:flutter/material.dart';
import 'package:food_delivery/pages/admin_pages/menu_page.dart';
import 'package:food_delivery/pages/admin_pages/order/order_page.dart';
import 'package:food_delivery/pages/admin_pages/product/product_page.dart';


class BottomNavAdmin extends StatefulWidget {
  final int storeId;

  const BottomNavAdmin({super.key, required this.storeId});

  @override
  State<BottomNavAdmin> createState() => _BottomNavAdminState();
}

class _BottomNavAdminState extends State<BottomNavAdmin> {
  late List<Widget> pages;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    pages = [
      // ProductPage(storeId: widget.storeId),
      ProductPage(storeId: widget.storeId),
      OrdersPage(storeId: widget.storeId),
      MenuPage(storeId: widget.storeId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentTabIndex], // Hiển thị trang theo index đã chọn
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTabIndex,
        selectedItemColor: Color(0xffef2b39),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Món ăn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        onTap: (value) {
          setState(() {
            currentTabIndex = value; // Thay đổi index khi người dùng chọn tab
          });
        },
      ),
    );
  }
}

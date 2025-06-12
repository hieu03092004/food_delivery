import 'package:flutter/material.dart';
import 'package:food_delivery/pages/authentication/PageAuthUser.dart';
import 'package:food_delivery/pages/customer_pages/cart/cart_page.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';

import 'package:food_delivery/service/customer_service/controller_cart.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCartIcon;
  const CommonAppBar({Key? key, this.title = '', this.showCartIcon = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final cartService = Get.find<ControllerCart>();
    Color themeOrange = Color(0xFFEE4D2D);
    print("id account ${auth.accountId.value}");

    return AppBar(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: themeOrange,
      centerTitle: true,
      actions:
          showCartIcon
              ? [
                Obx(() {
                  final count = cartService.distinctCount.value;
                  return badges.Badge(
                    // badgeStyle hoặc badgeColor tuỳ version badges
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.all(6),
                    ),
                    position: badges.BadgePosition.topEnd(top: -4, end: 8),
                    showBadge: count > 0,
                    badgeContent: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    child: Obx(() {
                      final loggedIn = auth.isLoggedIn;
                      final id = auth.accountId.value;

                      return IconButton(
                        padding: const EdgeInsets.only(right: 16.0, top: 4.0),
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          if (loggedIn) {
                            // Chuyển tới CartPage nếu đã đăng nhập
                            await Get.to(() => CartPage(accountId: id));
                            cartService.reload();
                            // Khi quay về, reload lại badge count
                          } else {
                            // Chưa login, chuyển đến trang auth
                            await Get.to(() => PageAuthUser());
                            cartService.reload();
                          }
                        },
                      );
                    }),
                  );
                }),
              ]
              : [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/config/database.dart';

import 'package:food_delivery/pages/authentication/PageAuthUser.dart';
import 'package:food_delivery/pages/customer_pages/bottom_customer_nav.dart';
import 'package:food_delivery/pages/customer_pages/cart/cart_page.dart';
import 'package:food_delivery/pages/shipper_pages/Notifications/notifications.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Database.init();
  // Put services vào GetX
  Get.put(AuthService(), permanent: true);
  Get.put(CartService(), permanent: true);

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // nếu cần xử lý dữ liệu khi ở background
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Khi app đang mở foreground
    FirebaseMessaging.onMessage.listen((msg) {
      // bạn có thể show in-app banner nếu muốn
    });

    // Khi app background hoặc terminated và user tap notification
    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      _navigateToNotifications();
    });
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) {
        _navigateToNotifications();
      }
    });
  }

  void _navigateToNotifications() {
    navigatorKey.currentState?.pushNamed('/notifications');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      // Không dùng initialRoute, dùng Obx để chọn home
      home: BottomCustomerNav(),
      // Khai báo routes (nếu cần navigation by name)
      getPages: [
        GetPage(
          name: '/cart',
          page: () {
            print("Loi roi ahuhu");
            final id = Get.find<AuthService>().accountId.value;
            return id != 0 ? CartPage(accountId: id) : const PageAuthUser();
          },
        ),
        GetPage(name: '/login', page: () => const PageAuthUser()),
        GetPage(name: '/notifications', page: () => const NotificationsPage()),
        // ... thêm các route khác nếu cần
      ],
    );
  }
}

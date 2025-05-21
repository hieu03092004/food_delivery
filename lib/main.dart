import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/api/firebase_api.dart';
import 'package:food_delivery/domains/authentication_respository/authentication_respository.dart';
import 'package:food_delivery/domains/data_source/firebase_auth_service.dart';
import 'package:food_delivery/pages/admin_pages/Bottom_nav_admin.dart';
import 'package:food_delivery/pages/authentication/authenticaion_state/authenticationCubit.dart';
import 'package:food_delivery/pages/authentication/bloc/login_cubit.dart';
import 'package:food_delivery/pages/authentication/login_page.dart';
import 'package:food_delivery/pages/customer_pages/bottom_customer_nav.dart';
import 'package:food_delivery/pages/shipper_pages/Bottom_nav_shipper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_delivery/pages/shipper_pages/Notifications/notifications.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/database.dart';
import 'model/shipper_model/Notification_model.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1) Khởi tạo Firebase và Database
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //await FirebaseApi().initNotifications();
  await Database.init();

  // 2) Build tree các Provider / Bloc
  runApp(
    MultiRepositoryProvider(
      providers: [
        // Đăng ký repo (dưới interface AuthenticationRepository)
        RepositoryProvider<AuthenticationRepository>(
          create: (_) => AuthenticationRepositoryImpl(FireBaseAuthService()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 3) LoginCubit chỉ lo việc gọi API login
          BlocProvider<LoginCubit>(
            create: (ctx) => LoginCubit(
              authenticationRepository: ctx.read<AuthenticationRepository>(),
            ),
          ),
          // 4) AuthenticationCubit giữ thông tin user toàn app
          BlocProvider<AuthenticationCubit>(
            create: (_) => AuthenticationCubit(),
          ),
        ],
        child: ChangeNotifierProvider(
          // <-- thêm provider ở đây
          create: (_) => NotificationProvider(2),
          child: const MyApp(),
        ),
      ),
    ),
  );
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
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginPage(),
        '/adminHome': (context) {
          final storeId = ModalRoute.of(context)!.settings.arguments as int;
          return BottomNavAdmin(storeId: storeId);
        },
        '/shipperHome': (ctx) => const BottomNavShipper(),
        '/customerHome': (ctx) => const BottomCustomerNav(),
        '/notifications': (ctx) => const NotificationsPage(),
      },
    );
  }
}

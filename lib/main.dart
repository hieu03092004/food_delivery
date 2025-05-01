import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/domains/authentication_respository/authentication_respository.dart';
import 'package:food_delivery/domains/data_source/firebase_auth_service.dart';
import 'package:food_delivery/pages/admin_pages/Bottom_nav_admin.dart';
import 'package:food_delivery/pages/authentication/login_page.dart';
import 'package:food_delivery/pages/customer_pages/bottom_customer_nav.dart';
import 'package:food_delivery/pages/shipper_pages/Bottom_nav_shipper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/database.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Database.init();
  runApp(const App());
}
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthenticationRepository _authenticationRepository;
  late final FireBaseAuthService _fireBaseAuthService;

  @override
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fireBaseAuthService=FireBaseAuthService();
    _authenticationRepository=AuthenticationRepositoryImpl(_fireBaseAuthService);
  }

  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (context) => _authenticationRepository,)],
      child: const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/adminHome': (context) => const BottomNavAdmin(),
        '/shipperHome': (context) => const BottomNavShipper(),
        '/customerHome': (context) => const BottomCustomerNav(),
      },
    );
  }
}

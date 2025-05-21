import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
@pragma('vm:entry-point')
Future<void> handelBackgroundMessage(RemoteMessage message) async {
  print("Vào đây");
  print('Title:${message.notification?.title}');
  print('Body:${message.notification?.body}');
  print('Payload:${message.data}');
}
class FirebaseApi{
  final _firebaseMessaging=FirebaseMessaging.instance;
  Future<void>initNotifications()async{
    await _firebaseMessaging.requestPermission();
    final fCMToken=await _firebaseMessaging.getToken();
    print('Token:$fCMToken');
    FirebaseMessaging.onBackgroundMessage(handelBackgroundMessage);
  }

}
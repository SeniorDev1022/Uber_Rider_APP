import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:uber_josh/common/Global_variable.dart';
import 'package:uber_josh/view_models/accept_view_modal.dart';
import 'package:uber_josh/view_models/order_view_model.dart';
import 'package:uber_josh/view_models/user_view_model.dart';
import 'package:uber_josh/views/arrived_page.dart';
import 'package:uber_josh/views/splashpage.dart'; // Import the new HomePage
// import 'package:uber_josh/view_models/notification_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA058qJVV7V1-b5P-VzKVD61rFMhXcoMhs',
      appId: '1:347373334103:android:0e8fabbe8fee2a2b9dbd12',
      messagingSenderId: '347373334103',
      projectId: 'kenorider-420a2',
      storageBucket: 'kenorider-420a2.appspot.com'
  ));
  navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => ArrivedPage()),
      );
  print("Handling a fg background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print("User granted permission: ${settings.authorizationStatus}");

  final fcmToken = await messaging.getToken();
  GlobalVariables.deviceToken = fcmToken;
  print("Fcmtoken$fcmToken");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => AcceptViewModel()) // Add NotificationProvider
      ],
      child: MyApp(fcmToken: fcmToken),
    ),
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    
    final acceptModel = navigatorKey.currentContext!.read<AcceptViewModel>();
      GlobalVariables.accepted = true;
      acceptModel.setData(message.data);
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      // final notificationProvider = navigatorKey.currentContext!.read<NotificationProvider>();
      // notificationProvider.setMessageData(message.data);
    }
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final String? fcmToken;
  MyApp({this.fcmToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Uber Josh',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Ensure this page is correctly implemented
    );
  }
}
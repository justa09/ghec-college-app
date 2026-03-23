import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Firebase init
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GHEC App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const NotificationHandler(
        // ✅ wrap with handler
        child: SplashScreen(),
      ),
    );
  }
}

// 🔥 Notification Handler
class NotificationHandler extends StatefulWidget {
  final Widget child;
  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  @override
  void initState() {
    super.initState();

    initFirebaseMessaging();
  }

  void initFirebaseMessaging() async {
    // 🔔 Permission
    await FirebaseMessaging.instance.requestPermission();

    // 🔥 Subscribe to topic
    await FirebaseMessaging.instance.subscribeToTopic("students");

    print("✅ Subscribed to topic: students");

    // 📩 Get token
    String? token = await FirebaseMessaging.instance.getToken();
    print("🔥 DEVICE TOKEN:");
    print(token);

    // 📲 Foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Notification Received:");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

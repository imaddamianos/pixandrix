import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pixandrix/api/firebase_api.dart';
import 'package:pixandrix/firebase/firebase_options.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/theme/custom_theme.dart';
import 'package:pixandrix/helpers/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  await FireBaseApi().initNotification();
  runApp(const MyApp());
   _initializeNotifications();
  getLocationPermission;
  _subscribeToOrders();
  _configureFirebaseMessaging();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          'logopixandrix'); // Replace 'icon' with your notification icon name
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void _showNotification(Map<String, dynamic>? data) async {
  if (data != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('order_notifications', 'Order Notifications',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Replace with a unique ID for the notification
      "New Order",
      "A new order has been added.",
      platformChannelSpecifics,
      payload: "item x", // Optional payload data as a String or Map
    );
  }
}

void _configureFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle incoming FCM messages here
    print('Received message: ${message.notification?.title}');
    // You can customize the handling of incoming messages, such as showing notifications
  });
}

void _subscribeToOrders() {
  FirebaseFirestore.instance
      .collection('orders')
      .snapshots()
      .listen((snapshot) {
    // Handle new documents added to the "orders" collection
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        // Document added, process it as needed
        // For example, you can show a notification here
        _showNotification(change.doc.data());
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: customTheme,
      home: const FirstPage(),
    );
  }
}

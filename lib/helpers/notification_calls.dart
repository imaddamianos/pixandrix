
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pixandrix/main.dart';

//  void subscribeToAdd(String driver) {
//     initializeNotifications();
//     configureFirebaseMessaging();
//     subscribeToaddOrders();
//     subscribeToChangedOrders(driver);
//   }

//   void subscribeToOwners() {
//     initializeNotifications();
//     configureFirebaseMessaging();
//     subscribeToTakenOrders();
//   }
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          'logopixandrix'); // Replace 'icon' with your notification icon name
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  configureFirebaseMessaging();
  _firebaseMessaging.onTokenRefresh
        .listen((fcmToken) {
          // Send token to your application server if needed
          if (fcmToken != null) {
            // Send the token to your server using your preferred method (e.g., HTTP request)
            print('FCM token refreshed: $fcmToken');
            // Replace with your actual server communication logic
            // ...
          }
        })
        .onError((err) {
          print('Error getting FCM token: $err');
        });
  }

void configureFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle incoming FCM messages here
    print('Received message: ${message.notification?.title}');
    // You can customize the handling of incoming messages, such as showing notifications
  });
}

void _showNotificationReject(Map<String, dynamic>? data) async {
  if (data != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('order_Returned', 'Order Returned',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Replace with a unique ID for the notification
      "Order Returned",
      "An order has been returned.",
      platformChannelSpecifics,
      payload: "item x", // Optional payload data as a String or Map
    );
  }
}

void _showNotificationAdd(Map<String, dynamic>? data) async {
  if (data != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('new_order', 'New Order',
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

void _showNotificationTaking(Map<String, dynamic>? data) async {
  if (data != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('order_Take', 'Order Take',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Replace with a unique ID for the notification
      "Order Taken",
      "An order has been Taken.",
      platformChannelSpecifics,
      payload: "item x", // Optional payload data as a String or Map
    );
  }
}

void subscribeToaddOrders(String userToken) {
  FirebaseFirestore.instance.collection('orders').snapshots().listen((snapshot) async {
    final fCMToken = await FirebaseMessaging.instance.getToken();
    for (var change in snapshot.docChanges) {
        _showNotificationAdd(change.doc.data());
    }
  });
}

void subscribeToChangedOrders(String driver, String orderNumber) {
  FirebaseFirestore.instance.collection('orders').snapshots().listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        var newData = change.doc.data() as Map<String, dynamic>;
        if (newData['status'] == 'OrderStatus.pending') {
          _showNotificationReject(newData);
        }
      }
    }
  });
}

void subscribeToTakenOrders() {
  FirebaseFirestore.instance.collection('orders').snapshots().listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        var newData = change.doc.data() as Map<String, dynamic>;
        if (newData['status'] == 'OrderStatus.inProgress') {
          _showNotificationTaking(newData);
        }
      }
    }
  });
}

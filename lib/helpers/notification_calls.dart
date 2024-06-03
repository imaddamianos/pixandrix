import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pixandrix/main.dart';
import 'dart:collection';


final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
// Set to track which notifications have already been sent
final Set<String> _sentNotifications = HashSet<String>();

void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('logopixandrix'); // Replace 'icon' with your notification icon name
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  configureFirebaseMessaging();
}

void configureFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle incoming FCM messages here
    print('Received message: ${message.notification?.title}');
    // You can customize the handling of incoming messages, such as showing notifications
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('Handling a background message: ${message.messageId}');
}

 void stopListening() {
       FirebaseFirestore.instance.terminate();
  }

void _showNotification(Map<String, dynamic>? data, String channelId, String channelName, String title, String body) async {
  if (data != null) {
    String notificationId = data['orderID'] ?? 'defaultId';
    if (_sentNotifications.contains(notificationId)) return;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channelId, channelName,
            importance: Importance.max, priority: Priority.high);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Replace with a unique ID for the notification
      title,
      body,
      platformChannelSpecifics,
      payload: "item x", // Optional payload data as a String or Map
    );

    // Mark the notification as sent
    _sentNotifications.add(notificationId);
  }
}

void _showNotificationAdd(Map<String, dynamic>? data) async {
  _showNotification(data, 'new_order', 'New Order', "New Order", "A new order has been added.");
}

void _showNotificationReturned(Map<String, dynamic>? data) async {
  _showNotification(data, 'order_Returned', 'Order Returned', "Order Returned", "An order has been returned.");
}

void _showNotificationTaking(Map<String, dynamic>? data) async {
  _showNotification(data, 'order_Take', 'Order Take', "Order Taken", "An order has been taken.");
}

void _showNotificationExceed() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('order_Exceed', 'Order Exceed',
          importance: Importance.max, priority: Priority.high);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0, // Replace with a unique ID for the notification
    "Order exceed 10 minutes",
    "An order has been exceeded the 10 minutes.",
    platformChannelSpecifics,
    payload: "item x", // Optional payload data as a String or Map
  );
}

void subscribeToDriverChangeOrders(String driver) {
  FirebaseFirestore.instance
      .collection('orders')
      .where('driverInfo', isEqualTo: driver)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var newData = change.doc.data() as Map<String, dynamic>;
            if (newData['driverInfo'] == driver) {
              _showNotificationTaking(change.doc.data());
            }
          }
        }
      });
}

void subscribeToaddOrders() {
  FirebaseFirestore.instance
      .collection('orders')
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _showNotificationAdd(change.doc.data());
          }else if (change.type == DocumentChangeType.modified) {
            var newData = change.doc.data() as Map<String, dynamic>;
             if (newData['status'] == 'OrderStatus.pending') {
            _showNotificationAdd(change.doc.data());
             }
          }
        }
      });
}

void subscribeToDriversReturnedOrders() {
  FirebaseFirestore.instance
      .collection('orders')
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.modified) {
            var newData = change.doc.data() as Map<String, dynamic>;
            if (newData['status'] == 'OrderStatus.pending') {
              _showNotificationReturned(newData);
            }
          }
        }
      });
}

void orderTimeExceed() {
  _showNotificationExceed();
}

void subscribeToOrderStatusChanges(String owner) {
  FirebaseFirestore.instance
      .collection('orders')
      .where('storeInfo', isEqualTo: owner)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.modified) {
            var newData = change.doc.data() as Map<String, dynamic>;
            if (newData['storeInfo'] == owner) {
              _showNotificationTaking(newData);
            }
          }
        }
      });
}

void subscribeToChangedOrders(String storeInfo, String orderID) {
  FirebaseFirestore.instance
      .collection('orders')
      .where('orderID', isEqualTo: orderID)
      .where('storeInfo', isEqualTo: storeInfo)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.modified) {
            var newData = change.doc.data() as Map<String, dynamic>;
            if (newData['status'] == 'OrderStatus.pending') {
              _showNotificationReturned(newData);
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

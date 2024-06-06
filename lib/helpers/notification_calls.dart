import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pixandrix/admin/orders_page.dart';
import 'package:pixandrix/helpers/location_helper.dart';
import 'package:pixandrix/drivers/drivers_home_page.dart';
import 'package:pixandrix/owners/owners_home_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
StreamSubscription<RemoteMessage>? _backgroundMessageSubscription;
List<StreamSubscription<QuerySnapshot>> _firestoreSubscriptions = [];

Future<void> initializeNotifications(BuildContext context, String type) async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('logopixandrix'); // Replace with notification icon
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null) {
        if (type == 'driver'){
          navigateAndRefresh(const DriversHomePage(), context);
        }else if(type == 'admin'){
          navigateAndRefresh(const OrdersPage(), context);
        }else if(type == 'owner'){
          navigateAndRefresh(const OwnersHomePage(), context);
        }
      }
    },
  );
  configureFirebaseMessaging();
}

void configureFirebaseMessaging() {
  _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received message: ${message.notification?.title}');
    _showNotification(
      message.data['channelId'] ?? 'default_channel',
      message.data['channelName'] ?? 'Default Channel',
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? 'You have a new notification',
    );
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  _showNotification(
    message.data['channelId'] ?? 'default_channel',
    message.data['channelName'] ?? 'Default Channel',
    message.notification?.title ?? 'Notification',
    message.notification?.body ?? 'You have a new notification',
  );
}

void stopListeningToNotifications() {
  for (var subscription in _firestoreSubscriptions) {
    subscription.cancel();
  }
  _firestoreSubscriptions.clear();
  
  _foregroundMessageSubscription?.cancel();
  _backgroundMessageSubscription?.cancel();
  FirebaseMessaging.onBackgroundMessage((message) async {}); // Remove background message handler
}

void _showNotification(String channelId, String channelName, String title, String body) async {
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
    payload: "driverHomePage", // Optional payload data as a String or Map
  );
}

void _showNotificationAdd(Map<String, dynamic>? data) async {
  _showNotification('new_order', 'New Order', "New Order", "A new order has been added.");
}

void _showNotificationReturned(Map<String, dynamic>? data) async {
  _showNotification('order_Returned', 'Order Returned', "Order Returned", "An order has been returned.");
}

void _showNotificationTaking(Map<String, dynamic>? data) async {
  _showNotification('order_Take', 'Order Take', "Order Taken", "An order has been taken.");
}

void orderTimeExceed() {
  _showNotificationExceed();
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
  var subscription = FirebaseFirestore.instance
      .collection('orders')
      .where('driverInfo', isEqualTo: driver)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var newData = change.doc.data() as Map<String, dynamic>;
            if (newData['driverInfo'] == driver) {
              _showNotificationTaking(newData);
            }
          }
        }
      });
  _firestoreSubscriptions.add(subscription);
}

void subscribeToaddOrders() {
  var subscription = FirebaseFirestore.instance
      .collection('orders')
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var newData = change.doc.data() as Map<String, dynamic>;
            if (newData['status'] == 'OrderStatus.pending') {
              _showNotificationAdd(change.doc.data());
            }
          }
        }
      });
  _firestoreSubscriptions.add(subscription);
}

void subscribeToDriversReturnedOrders() {
  var subscription = FirebaseFirestore.instance
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
  _firestoreSubscriptions.add(subscription);
}

void subscribeToOrderStatusChanges(String owner) {
  var subscription = FirebaseFirestore.instance
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
  _firestoreSubscriptions.add(subscription);
}

void subscribeToChangedOrders(String storeInfo, String orderID) {
  var subscription = FirebaseFirestore.instance
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
  _firestoreSubscriptions.add(subscription);
}

void subscribeToTakenOrders() {
  var subscription = FirebaseFirestore.instance.collection('orders').snapshots().listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        var newData = change.doc.data() as Map<String, dynamic>;
        if (newData['status'] == 'OrderStatus.inProgress') {
          _showNotificationTaking(newData);
        }
      }
    }
  });
  _firestoreSubscriptions.add(subscription);
}

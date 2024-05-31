
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pixandrix/main.dart';

void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          'logopixandrix'); // Replace 'icon' with your notification icon name
  const InitializationSettings initializationSettings =
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
}

void _showNotification(Map<String, dynamic>? data) async {
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


void _showNotificationReturned(Map<String, dynamic>? data) async {
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
            _showNotification(change.doc.data());
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
            _showNotification(change.doc.data());
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

void subscribeToOrderStatusChanges(String owner) {
  FirebaseFirestore.instance
      .collection('orders')
      .where('storeInfo', isEqualTo: owner)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.modified ) {
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

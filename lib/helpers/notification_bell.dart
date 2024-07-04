import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pixandrix/admin/admin_panel.dart';
import 'package:pixandrix/drivers/drivers_home_page.dart';
import 'package:pixandrix/helpers/location_helper.dart';
import 'package:pixandrix/owners/owners_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationService = NotificationService();
 String? selectedSound;

class NotificationService {
   int _notificationCount = 0;
  final ValueNotifier<int> notificationCountNotifier = ValueNotifier<int>(0);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _backgroundMessageSubscription;
  static String? selectedSound;
  final List<StreamSubscription> _databaseSubscriptions = [];

   Future<void> initializeNotifications(
      BuildContext context, String type) async {

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            'logopixandrix'); // Replace with notification icon
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          if (type == 'driver') {
            navigateAndRefresh(const DriversHomePage(), context);
          } else if (type == 'admin') {
            navigateAndRefresh(const AdminPanelPage(), context);
          } else if (type == 'owner') {
            navigateAndRefresh(const OwnersHomePage(), context);
          }
        }
      },
    );
    await loadSelectedSound();
    // configureFirebaseMessaging();
  }

  Future<void> loadSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
      selectedSound = prefs.getString('selectedSound');
  }

  // void configureFirebaseMessaging() {
  //   _foregroundMessageSubscription =
  //       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     if (message.notification != null) {
  //       _showNotification(
  //         message.data['channelId'] ?? 'default_channel',
  //         message.data['channelName'] ?? 'Default Channel',
  //         message.notification?.title ?? 'Notification',
  //         message.notification?.body ?? 'You have a new notification'
  //       );
  //     }
  //   });
  // }

//  static Future<void> _firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {
//     if (message.notification != null) {
//       _showNotification(
//         message.data['channelId'] ?? 'default_channel',
//         message.data['channelName'] ?? 'Default Channel',
//         message.notification?.title ?? 'Notification',
//         message.notification?.body ?? 'You have a new notification'
//       );
//     }
//   }

   static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Message received while the app is in the background: ${message.messageId}');
  }

  void addNotificationCount() {
    _notificationCount++;
    notificationCountNotifier.value = _notificationCount;
  }

  int get notificationCount => _notificationCount;

  void resetNotificationCount() {
    _notificationCount = 0;
    notificationCountNotifier.value = 0;
  }

  void stopListeningToNotifications() {
    for (var subscription in _databaseSubscriptions) {
      subscription.cancel();
    }
    _databaseSubscriptions.clear();

    _foregroundMessageSubscription?.cancel();
    _backgroundMessageSubscription?.cancel();
    FirebaseMessaging.onBackgroundMessage(
        (message) async {}); // Remove background message handler
  }

  static void _showNotification(
    String channelId,
    String channelName,
    String title,
    String body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final customSoundPath = prefs.getString('selectedSound');
    AndroidNotificationDetails androidPlatformChannelSpecifics;
     if (customSoundPath == null || customSoundPath.isEmpty) {
      // Use default notification sound
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
      //  sound: const RawResourceAndroidNotificationSound('default_sound'), // This uses the default system notification sound
      );
     }else{
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
       sound: RawResourceAndroidNotificationSound(customSoundPath.split('/').last.split('.').first),
      );
     }
     NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void _showNotificationAdd(Map<String, dynamic>? data) async {
    addNotificationCount();
    _showNotification(
        'new_order', 'New Order', "New Order", "A new order has been added.");
  }

  void _showNotificationReturned(Map<String, dynamic>? data) async {
    addNotificationCount();
    _showNotification('order_Returned', 'Order Returned', "Order Returned",
        "An order has been returned.");
  }

  void _showNotificationTaking(Map<String, dynamic>? data) async {
    addNotificationCount();
    _showNotification(
        'order_Take', 'Order Take', "Order Taken", "Order has been taken.");
  }

  void _orderTimeExceed(Map<String, dynamic>? data) async {
    addNotificationCount();
    _showNotification('order_Exceed', 'Order Exceed', "Order exceed 10 minutes",
        "An order has been exceeded the 10 minutes.");
  }

  void _showNewHelpRequest(Map<String, dynamic>? data) async {
    addNotificationCount();
    _showNotification(
        'help_driver', 'help driver', "Help!", "A driver need your help");
  }

  void subscribeTotimeExceed() {
    var subscription = FirebaseDatabase.instance
        .ref('orders')
        .orderByChild('isTaken')
        .onValue
        .listen((event) {
      for (var change in event.snapshot.children) {
        var newData =
            Map<String, dynamic>.from(change.value as Map); // Safe type cast
        if (newData['isTaken']) {
          _orderTimeExceed(newData);
        }
      }
    });
    _databaseSubscriptions.add(subscription);
  }

  void subscribeToHelp(String driver) {
    var subscription = FirebaseDatabase.instance
        .ref('helpRequests')
        .onChildAdded
        .listen((event) {
      var newData = Map<String, dynamic>.from(
          event.snapshot.value as Map); // Safe type cast
      if (newData['isHelped'] == false) {
        _showNewHelpRequest(newData);
      }
    });
    _databaseSubscriptions.add(subscription);
  }

  void subscribeToDriverChangeOrders(String driver) {
    var subscription = FirebaseDatabase.instance
        .ref('orders')
        .orderByChild('driverInfo')
        .equalTo(driver)
        .onChildAdded
        .listen((event) {
      var newData = Map<String, dynamic>.from(
          event.snapshot.value as Map); // Safe type cast
      if (newData['driverInfo'] == driver) {
        _showNotificationTaking(newData);
      }
    });
    _databaseSubscriptions.add(subscription);
  }

  void subscribeToaddOrders() {
    var subscription =
        FirebaseDatabase.instance.ref('orders').onChildAdded.listen((event) {
      var newData = Map<String, dynamic>.from(
          event.snapshot.value as Map); // Safe type cast
      if (newData['status'] == 'OrderStatus.pending') {
        _showNotificationAdd(newData);
      }
    });
    _databaseSubscriptions.add(subscription);
  }

  void subscribeToDriversReturnedOrders() {
    var subscription =
        FirebaseDatabase.instance.ref('orders').onChildChanged.listen((event) {
      var newData = Map<String, dynamic>.from(
          event.snapshot.value as Map); // Safe type cast
      if (newData['orderTimeTaken'] != newData['lastOrderTimeUpdate']) {
        _showNotificationReturned(newData);
      }
    });
    _databaseSubscriptions.add(subscription);
  }

  void subscribeToOrderStatusChanges(String owner) {
    var subscription = FirebaseDatabase.instance
        .ref('orders')
        .orderByChild('storeInfo')
        .equalTo(owner)
        .onChildChanged
        .listen((event) {
      var newData = Map<String, dynamic>.from(
          event.snapshot.value as Map); // Safe type cast
      if (newData['storeInfo'] == owner) {
        _showNotificationTaking(newData);
      }
    });
    _databaseSubscriptions.add(subscription);
  }

  void subscribeToChangedOrders(String storeInfo, String orderID) {
    var subscription = FirebaseDatabase.instance
        .ref('orders')
        .orderByChild('orderID')
        .equalTo(orderID)
        .onChildChanged
        .listen((event) {
      var newData = Map<String, dynamic>.from(
          event.snapshot.value as Map); // Safe type cast
      if (newData['storeInfo'] == storeInfo &&
          newData['status'] == 'OrderStatus.pending') {
        _showNotificationReturned(newData);
      }
    });
    _databaseSubscriptions.add(subscription);
  }

  void subscribeToTakenOrders() {
    var subscription =
        FirebaseDatabase.instance.ref('orders').onChildChanged.listen((event) {
      var newData = Map<String, dynamic>.from(
          event.snapshot.value as Map); // Safe type cast
      if (newData['status'] == 'OrderStatus.inProgress') {
        _showNotificationTaking(newData);
      }
    });
    _databaseSubscriptions.add(subscription);
  }
}

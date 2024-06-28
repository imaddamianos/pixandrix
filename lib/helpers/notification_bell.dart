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

final notificationService = NotificationService();
bool _hasSubscribedToOrderTimeExceed = false; // Flag to track subscription

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
    await Firebase.initializeApp();
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
    configureFirebaseMessaging();
  }

  void configureFirebaseMessaging() {
    _foregroundMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      if (message.notification != null) {
        _showNotification(
          message.data['channelId'] ?? 'default_channel',
          message.data['channelName'] ?? 'Default Channel',
          message.notification?.title ?? 'Notification',
          message.notification?.body ?? 'You have a new notification',
        );
      }
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (message.notification != null) {
      _showNotification(
        message.data['channelId'] ?? 'default_channel',
        message.data['channelName'] ?? 'Default Channel',
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'You have a new notification',
      );
    }
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
      String channelId, String channelName, String title, String body) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      // sound: const RawResourceAndroidNotificationSound('collectring.mp3'), // Custom sound added here
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      0, // Replace with a unique ID for the notification
      title,
      body,
      platformChannelSpecifics,
      payload: "driverHomePage", // Optional payload data as a String or Map
    );
  }

  Future<void> showOngoingNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // This makes the notification ongoing
      autoCancel:
          false, // This prevents the user from dismissing the notification
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Ongoing Notification',
      'You are currently available for orders.',
      platformChannelSpecifics,
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

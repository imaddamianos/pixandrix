import 'package:flutter/material.dart';
import 'package:pixandrix/drivers/ask_for_help.dart';
import 'package:pixandrix/drivers/help_driver_list.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/helpers/notification_bell.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/helpRequest_model.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/orders/order_card_drivers.dart';
import 'package:pixandrix/orders/order_card_drivers_windows.dart';
import 'package:pixandrix/settings_page.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _secureStorage = SecureStorage();

class DriversHomePage extends StatefulWidget {
  final DriverData? driverInfo;
  const DriversHomePage({Key? key, this.driverInfo}) : super(key: key);

  @override
  _DriversHomePageState createState() => _DriversHomePageState();
}

class _DriversHomePageState extends State<DriversHomePage> with RouteAware, WidgetsBindingObserver {
  DriverData? driverInfo;
  List<HelpRequestData>? helpRequest;
  bool notificationsSubscribed = false;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadDriverInfo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadDriverInfo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

   Future<void> loadDriverInfo() async {
     _secureStorage.setAutoLoginStatus(false, 'driver');
    driverInfo = await getDriverInfo();
    if (mounted) {
      setState(() {
        // Notifications are subscribed only once
        if (!notificationsSubscribed && driverInfo != null) {
          notificationSubscribe();
          notificationsSubscribed = true;
        }
        // Retrieve help requests for the driver
        helpRequest = []; // Initialize as empty list
        // if (driverInfo != null) {
          loadHelpRequests(driverInfo!.name);
        // }
      });
    }
  }

  Future<DriverData?> getDriverInfo() async {
    final savedDriver = await _secureStorage.getDriver();
    final savedPassword = await _secureStorage.getDriverPassword();
    return FirebaseOperations.checkDriverCredentials(
        'drivers', savedDriver!, savedPassword!);
  }

  void changeDriverStatus(bool value) {
    driverInfo!.isAvailable = value;
    FirebaseOperations.changeDriverAvailable(driverInfo!.name, value);
    notificationSubscribe();
    if (value) {
      notificationService.showOngoingNotification();
    } else {
      notificationService.stopListeningToNotifications();
    }
  }

  void notificationSubscribe() {
    if (driverInfo!.isAvailable) {
      notificationService.initializeNotifications(context, 'driver');
      notificationService.subscribeToaddOrders();
      notificationService.subscribeToHelp(driverInfo!.name);
    } else {
      notificationService.stopListeningToNotifications();
    }
  }

  // Method to retrieve help requests for the driver
  Future<void> loadHelpRequests(String driverName) async {
    final helpRequests = await FirebaseOperations.getHelpRequest();
    setState(() {
      helpRequest = helpRequests;
    });
  }

  Future<void> _changeOrderStatus(int index, List<OrderData> orders) async {
    final orderToChange = orders[index].orderID;
    final lastOrderTimeUpdate = orders[index].lastOrderTimeUpdate.toDate();
    final driver = driverInfo?.name;
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(lastOrderTimeUpdate);
    final status = orders[index].status;


    if (status == 'OrderStatus.pending') {
      await FirebaseOperations.changeOrderStatus(
          'OrderStatus.inProgress', orderToChange, driver!);
    } else if (status == 'OrderStatus.inProgress') {
      if (timeSinceLastUpdate.inMinutes >= 5) {
        showAlertChangeProgress(
          context,
          'Finish Order',
          "Are you sure you want to finish the order?",
          'OrderStatus.inProgress',
          orderToChange,
          driver!,
          () => setState(() {}),
        );
      } else {
        showAlertDialog(
          context,
          'Alert!',
          'You need to wait at least 5 minutes from the accept time of the order before finishing it.',
        );
      }
    }
  }

  Future<void> _cancelOrderStatus(int index, List<OrderData> orders) async {
    final orderNumber = orders[index].orderID;
    final status = orders[index].status;
    if (status == 'OrderStatus.inProgress') {
      showAlertDriverCancelOrder(
        context,
        'Cancel order',
        'Are you sure you want to cancel the order',
        orderNumber,
        () => setState(() {}),
      );
    }
  }

  int _countDriverOrders(String driverName, List<OrderData> orders) {
    if (driverName.isEmpty) {
      return 0;
    }
    return orders.where((order) => order.driverInfo == driverName).length;
  }

  Future<void> handleChangeStatus(int index, BuildContext context, DriverData? driverInfo) async {
  setState(() {
    _isLoading = true;  // Show the loader
  });

  try {
    // Fetch the latest orders from Firestore
    final snapshot = await FirebaseFirestore.instance.collection('orders').get();
    final orders = snapshot.docs.map((doc) => OrderData.fromDocument(doc)).toList();

    final status = orders[index].status;
    final driverOrder = orders[index].driverInfo;
    final currentDriver = driverInfo?.name;
    int driverOrderCount = 0;

    for (final order in orders) {
      if (order.driverInfo == currentDriver) {
        driverOrderCount++;
      }
      if (order.status == 'OrderStatus.delivered') {
        driverOrderCount--;
      }
    }

    if ((driverOrderCount < 2 && status == 'OrderStatus.pending' && driverOrder == '') ||
        (status == 'OrderStatus.inProgress' && driverOrder == currentDriver)) {
      await _changeOrderStatus(index, orders);
      await loadDriverInfo();
    } else {
      showAlertDialog(
        context,
        'Alert!',
        'Hi $currentDriver, \nIt looks like you already have 2 orders assigned. Please wait for 20 minutes before accepting new orders.',
      );
    }
  } finally {
    setState(() {
      _isLoading = false;  // Hide the loader
    });
  }
}

  @override
  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      return false;
    },
    child: Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(driverInfo?.name ?? ''),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(driverInfo?.driverImage ?? ''),
          ),
        ),
        actions: [
          Row(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: notificationService.notificationCountNotifier,
                builder: (context, notificationCount, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          notificationService.resetNotificationCount();
                        },
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  notificationService.stopListeningToNotifications();
                  showAlertWithDestination(context, 'Log Out',
                      'Are you sure you want to Log out?', const FirstPage());
                },
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          driverInfo == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          // No orders
                        }

                        final orders = snapshot.data!.docs.map((doc) {
                          return OrderData.fromDocument(doc);
                        }).toList();

                        orders.sort((a, b) {
                          const statusOrder = {
                            'OrderStatus.pending': 0,
                            'OrderStatus.inProgress': 1,
                            'OrderStatus.delivered': 2,
                          };
                          return statusOrder[a.status]!
                              .compareTo(statusOrder[b.status]!);
                        });

                        return Column(
                          children: [
                            // Banner to display when driver is available
                            if (driverInfo!.isAvailable)
                              Container(
                                color: Colors.green,
                                padding: const EdgeInsets.all(10),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'You are available!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            helpButton(
                              text: 'Ask for Help',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AskForHelpPage(driverInfo: driverInfo),
                                  ),
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Orders: ${_countDriverOrders(driverInfo?.name ?? '', orders)} ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                HelpDriverButton(
                                  helpRequests: helpRequest ?? [],
                                  onHelped: () => setState(() {
                                    loadHelpRequests(driverInfo!.name);
                                  }),
                                ),
                                Column(
                                  children: [
                                    Switch(
                                      value: driverInfo?.isAvailable ?? false,
                                      onChanged: (value) {
                                        if (driverInfo != null) {
                                          setState(() {
                                            changeDriverStatus(value);
                                          });
                                        }
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                    ),
                                    const Text('Status'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  if (orders[index].driverInfo == '' ||
                                      orders[index].driverInfo ==
                                          driverInfo?.name) {
                                    return Column(
                                      children: [
                                        OrderCardDrivers(
                                          orderTime: orders[index].orderTime,
                                          orderLocation:
                                              orders[index].orderLocation,
                                          status: orders[index].status,
                                          driverInfo: orders[index].driverInfo,
                                          storeInfo: orders[index].storeInfo,
                                          press: () {
                                            String orderID =
                                                orders[index].orderID;
                                            String orderAddress =
                                                orders[index].orderLocation;
                                            if (orderID.isEmpty) {
                                              orderID = 'No driver';
                                            }
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  OrderCardDriversWindow(
                                                ownerName:
                                                    orders[index].storeInfo,
                                                orderID: orderID,
                                                orderAddress: orderAddress,
                                              ),
                                            );
                                          },
                                          onChangeStatus: () async {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            await Future.delayed(
                                                const Duration(seconds: 2));
                                            await handleChangeStatus(
                                                index, context, driverInfo);
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          },
                                          onCancel: () {
                                            _cancelOrderStatus(index, orders);
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    ),
  );
}
}

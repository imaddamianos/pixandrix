import 'package:flutter/material.dart';
import 'package:pixandrix/drivers/ask_for_help.dart';
import 'package:pixandrix/drivers/help_driver_list.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/helpers/notification_calls.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/helpRequest_model.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/orders/order_card_drivers.dart';
import 'package:pixandrix/orders/order_card_drivers_windows.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';

final _secureStorage = SecureStorage();

class DriversHomePage extends StatefulWidget {
  final DriverData? driverInfo;
  const DriversHomePage({Key? key, this.driverInfo}) : super(key: key);

  @override
  _DriversHomePageState createState() => _DriversHomePageState();
}
class _DriversHomePageState extends State<DriversHomePage> with RouteAware, WidgetsBindingObserver {
  DriverData? driverInfo;
  List<OrderData>? orders;
  List<HelpRequestData>? helpRequest;
  bool notificationsSubscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadDriverInfo().then((_) {
      loadOrders();
    });
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
    driverInfo = await getDriverInfo();
    if (mounted) {
      setState(() {
        // Notifications are subscribed only once
        if (!notificationsSubscribed && driverInfo != null) {
          notificationSubscribe();
          notificationsSubscribed = true;
        }
      });
    }
  }

  Future<DriverData?> getDriverInfo() async {
    final savedDriver = await _secureStorage.getDriver();
    final savedPassword = await _secureStorage.getDriverPassword();
    return FirebaseOperations.checkDriverCredentials('drivers', savedDriver!, savedPassword!);
  }

  Future<void> loadOrders() async {
    try {
      final fetchedOrders = await FirebaseOperations.getOrders();
      orders = fetchedOrders.cast<OrderData>();
      fetchedOrders.sort((a, b) {
      const statusOrder = {
        'OrderStatus.pending': 0,
        'OrderStatus.inProgress': 1,
        'OrderStatus.delivered': 2,
      };
      return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
    });

      if (mounted) {
        setState(() {
          // changeDriverStatus(driverInfo!.isAvailable);
        });
      }
      _loadHelpRequest();
    } catch (e) {
      // Handle error
    }
  }
  void changeDriverStatus(bool value) {
    driverInfo!.isAvailable = value;
    FirebaseOperations.changeDriverAvailable(driverInfo!.name, value);
      notificationSubscribe();
  }

  Future<void> _loadHelpRequest() async {
    final fetchedHelps = await FirebaseOperations.getHelpRequest();
    helpRequest = fetchedHelps.cast<HelpRequestData>();
    if (mounted) {
      setState(() {});
    }
  }

  void notificationSubscribe() {
    if(driverInfo!.isAvailable){
initializeNotifications(context, 'driver');
    subscribeToaddOrders();
    subscribeToDriversReturnedOrders();
    // subscribeToDriverChangeOrders(driverInfo!.name);
    }else{
      stopListeningToNotifications();
    }
    
  }

  Future<void> _changeOrderStatus(int index) async {
    final orderToChange = orders![index].orderID;
    final lastOrderTimeUpdate = orders![index].lastOrderTimeUpdate.toDate();
    final driver = driverInfo?.name;
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(lastOrderTimeUpdate);
    final status = orders![index].status;

    if (status == 'OrderStatus.pending') {
      if (index >= 0 && index < orders!.length) {
        DateTime now = DateTime.now().toLocal();
              if (status == 'OrderStatus.pending') {
                await FirebaseOperations.changeOrderStatus(
                    'OrderStatus.inProgress', orderToChange, now);
                await FirebaseOperations.changeDriverName(
                    driver!, orderToChange);
              }
      }
    } else if (orders![index].status == 'OrderStatus.inProgress') {
      if (timeSinceLastUpdate.inMinutes >= 5) {
        if (index >= 0 && index < orders!.length) {
          showAlertChangeProgress(
              context,
              'Finish Order',
              "Are you sure you want to finish the order?",
              'OrderStatus.inProgress',
              orderToChange,
              driver!,
              loadOrders);
        }
      } else {
        showAlertDialog(context, 'Alert!',
            'You need to wait at least 5 minutes from the accept time of the order before finishing it.');
      }
    }

    await loadOrders();
  }

  Future<void> _cancelOrderStatus(int index) async {
    final orderNumber = orders![index].orderID;
    final status = orders![index].status;
    if (status == 'OrderStatus.inProgress') {
      if (index >= 0 && index < orders!.length) {
        showAlertDriverCancelOrder(
            context,
            'Cancel order',
            'Are you sure you want to cancel the order',
            orderNumber,
            loadOrders);
      }
    }
  }

  int _countDriverOrders(String driverName) {
    if (orders == null || driverName.isEmpty) {
      return 0;
    }
    return orders!.where((order) => order.driverInfo == driverName).length;
  }

  // Future<void> refreshOrders() async {
  //   await loadOrders();
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(driverInfo?.name ?? 'Driver Name'),
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
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    showAlertWithDestination(context, 'Log Out',
                        'Are you sure you want to Log out?', const FirstPage());
                  },
                ),
              ],
            ),
          ],
        ),
        body: driverInfo == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: RefreshIndicator(
                  onRefresh: loadOrders,
                  child: Column(
                    children: [
                      helpButton(
                          text: 'Ask for Help',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AskForHelpPage(driverInfo: driverInfo),
                              ),
                            );
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Orders: ${_countDriverOrders(driverInfo?.name ?? '')} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          HelpDriverButton(
                              helpRequests: helpRequest ?? [],
                              onHelped: _loadHelpRequest),
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
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: orders == null
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: orders!.length,
                                itemBuilder: (context, index) {
                                  if (orders![index].driverInfo == '' ||
                                      orders![index].driverInfo == driverInfo?.name) {
                                    return Column(
                                      children: [
                                        OrderCardDrivers(
                                          orderTime: orders![index].orderTime,
                                          orderLocation: orders![index].orderLocation,
                                          status: orders![index].status,
                                          driverInfo: orders![index].driverInfo,
                                          storeInfo: orders![index].storeInfo,
                                          press: () {
                                            String orderID = orders![index].orderID;
                                            String orderAddress =
                                                orders![index].orderLocation;
                                            if (orderID.isEmpty) {
                                              orderID = 'No driver';
                                            }
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  OrderCardDriversWindow(
                                                      ownerName:
                                                          orders![index].storeInfo,
                                                      orderID: orderID,
                                                      orderAddress: orderAddress),
                                            );
                                          },
                                          onChangeStatus: () async {
                                            final status = orders![index].status;
                                            final driverOrder =
                                                orders![index].driverInfo;
                                            final currentDriver = driverInfo?.name;

                                            int driverOrderCount = 0;
                                            for (final order in orders!) {
                                              if (order.driverInfo == currentDriver) {
                                                driverOrderCount++;
                                              }
                                              if (order.status ==
                                                  'OrderStatus.delivered') {
                                                driverOrderCount--;
                                              }
                                            }
                                            if (driverOrderCount < 2 &&
                                                    status == 'OrderStatus.pending' &&
                                                    driverOrder == '' ||
                                                status == 'OrderStatus.inProgress' &&
                                                    driverOrder == currentDriver) {
                                              await _changeOrderStatus(
                                                  index); // Change status for pending orders without driver or in-progress with current driver
                                              await loadOrders();
                                            } else {
                                              showAlertDialog(context, 'Alert!',
                                                  'Hi $currentDriver,  \nIt looks like you already have 2 orders assigned. Please wait for 20 minutes before accepting new orders.');
                                            }
                                          },
                                          onCancel: () {
                                            _cancelOrderStatus(index);
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox
                                        .shrink(); // Return an empty SizedBox if driverInfo is not empty
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}


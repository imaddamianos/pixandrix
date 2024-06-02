import 'package:flutter/material.dart';
import 'package:pixandrix/drivers/ask_for_help.dart';
import 'package:pixandrix/drivers/help_driver_list.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/helpers/notification_calls.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/helpRequest_model.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/orders/order_card_drivers.dart';
import 'package:pixandrix/orders/order_card_drivers_windows.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';

class DriversHomePage extends StatefulWidget {
  final DriverData? driverInfo;
  const DriversHomePage({super.key, this.driverInfo});

  @override
  _DriversHomePageState createState() => _DriversHomePageState();
}

class _DriversHomePageState extends State<DriversHomePage> {
  late DriverData? driverInfo;
  List<OrderData>? orders;
  List<HelpRequestData>? helpRequest;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    subscribeToaddOrders();
    subscribeToDriversReturnedOrders();
    subscribeToDriverChangeOrders(widget.driverInfo!.name);
    driverInfo = widget.driverInfo; // Initialize driverInfo in initState
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      // Fetch orders data and cast it to a List<OrderData>
      final fetchedOrders = await FirebaseOperations.getOrders();
      orders = fetchedOrders.cast<OrderData>();

      if (mounted) {
        setState(() {}); // Trigger a rebuild to reflect the updated orders data
      }
      _loadHelpRequest();
    } catch (e) {}
  }

  Future<void> _loadHelpRequest() async {
    // Fetch help requests data and cast it to a List<HelpRequestData>
    final fetchedHelps = await FirebaseOperations.getHelpRequest();
    helpRequest = fetchedHelps.cast<HelpRequestData>();

    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated help requests data
    }
  }

  Future<void> _changeOrderStatus(int index) async {
    final orderToChange = orders![index].orderID;
    final lastOrderTimeUpdate = orders![index].lastOrderTimeUpdate.toDate();
    final driver = driverInfo?.name;
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(lastOrderTimeUpdate);

    if (orders![index].status == 'OrderStatus.pending') {
      if (index >= 0 && index < orders!.length) {
        showAlertChangeProgress(
            context,
            'Take Order',
            "Are you sure you want to take the order?",
            'OrderStatus.pending',
            orderToChange,
            driver!,
            _loadOrders);
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
              _loadOrders);
        }
      } else {
        showAlertDialog(context, 'Alert!',
            'You need to wait at least 5 minutes from the accept time of the order before finishing it.');
      }
    }

    await _loadOrders(); // Refresh the orders list after status change
  }

  Future<void> _cancelOrderStatus(int index) async {
    // cancel order from driver
    final orderNumber = orders![index].orderID;
    final status = orders![index].status;
    if (status == 'OrderStatus.inProgress') {
      if (index >= 0 && index < orders!.length) {
        showAlertDriverCancelOrder(
            context,
            'Cancel order',
            'Are you sure you want to cancel the order',
            orderNumber,
            _loadOrders);
      }
    }
  }

  int _countDriverOrders(String driverName) {
    if (orders == null || driverName.isEmpty) {
      return 0;
    }
    return orders!.where((order) => order.driverInfo == driverName).length;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // This widget will intercept the back button press
      onWillPop: () async {
        // Return false to prevent the back button action
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: _loadOrders,
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
                    HelpDriverButton(helpRequests: helpRequest ?? []),
                    Column(
                      children: [
                        Switch(
                          value: driverInfo!.isAvailable,
                          onChanged: (value) {
                            setState(() {
                              driverInfo!.isAvailable = value;
                            });
                            FirebaseOperations.changeDriverAvailable(
                                driverInfo!.name, value);
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
                                        await _loadOrders();
                                        // }
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

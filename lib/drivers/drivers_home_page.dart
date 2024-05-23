import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/orders/order_card_drivers.dart';
import 'package:pixandrix/orders/order_card_drivers_windows.dart';

class DriversHomePage extends StatefulWidget {
  final DriverData? driverInfo;
  const DriversHomePage({super.key, this.driverInfo});

  @override
  _DriversHomePageState createState() => _DriversHomePageState();
}

class _DriversHomePageState extends State<DriversHomePage> {
  late DriverData? driverInfo;
  List<OrderData>? orders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    driverInfo = widget.driverInfo; // Initialize driverInfo in initState
  }

  Future<void> _loadOrders() async {
    // Fetch orders data and cast it to a List<OrderData>
    final fetchedOrders = await FirebaseOperations.getOrders();
    orders = fetchedOrders.cast<OrderData>();

    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated orders data
    }
  }

  Future<void> _changeOrderStatus(
    int index,
  ) async {
    // change the status from driver
    final orderToChange = orders![index].orderID;
    final driver = driverInfo?.name;
    if (orders![index].status == 'OrderStatus.pending') {
      if (index >= 0 && index < orders!.length) {
showAlertChangeProgress(context, 'Take Order', "Are you sure you want to take the order?", 'OrderStatus.pending', orderToChange, driver!, _loadOrders);

      }
    } else {
      if (index >= 0 && index < orders!.length) {
          showAlertChangeProgress(context, 'Finish Order', "Are you sure you want to finish the order?", 'OrderStatus.inProgress', orderToChange, driver!, _loadOrders);
      }
    }
    _loadOrders(); // Refresh the drivers list after removing the driver
  }

  Future<void> _cancelOrderStatus(
    int index,
  ) async {
    // cancel order from driver
    final orderToChange = orders![index].orderID;
    if (index >= 0 && index < orders!.length) {
      await FirebaseOperations.changeOrderStatus(
          'OrderStatus.pending', orderToChange);
      await FirebaseOperations.changeDriverName('', orderToChange);
    }
    // }
    _loadOrders(); // Refresh the drivers list after removing the driver
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FirstPage()),
                    );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Orders: ${orders?.length ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                                      final status = orders![index].status;
                                      if (status != 'OrderStatus.delivered') {
                                        _cancelOrderStatus(index);
                                      }
                                      _loadOrders();
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

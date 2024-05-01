import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/widgets/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPagePageState createState() => _OrdersPagePageState();
}

class _OrdersPagePageState extends State<OrdersPage> {
  List<OrderData>? orders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    // Fetch drivers data and cast it to a List<DriverData>
    final fetchedOrders = await FirebaseOperations.getOrders();
    orders = fetchedOrders.cast<OrderData>();

    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated drivers data
    }
  }

  Future<void> _removeOrder(int index) async {
    // Remove the driver at the specified index from the list
    if (index >= 0 && index < orders!.length) {
      final orderToRemove = orders![index];
      await FirebaseOperations.removeOrder(orderToRemove.orderID);
      _loadOrders(); // Refresh the drivers list after removing the driver
    }
  }

  Future<void> _changeOrderStatus(
    int index,
  ) async {
    // Remove the driver at the specified index from the list
    final orderToChange = orders![index].orderID;
    if (orders![index].status == 'OrderStatus.pending') {
      if (index >= 0 && index < orders!.length) {
        await FirebaseOperations.changeOrderStatus(
            'OrderStatus.inProgress', orderToChange);
      }
    } else if (orders![index].status == 'OrderStatus.inProgress') {
      if (index >= 0 && index < orders!.length) {
        await FirebaseOperations.changeOrderStatus(
            'OrderStatus.delivered', orderToChange);
      }
    }
    _loadOrders(); // Refresh the drivers list after removing the driver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AddButton(
            //   text: 'Add Drivers',
            //   onPressed: () async {
            //     // Navigate to the AddDriverPage and await the result
            //     await Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const AddDriverPage()),
            //     );
            //     // Refresh the drivers list after adding a new driver
            //     _loadDrivers();
            //   },
            // ),
            const SizedBox(height: 20),
            Expanded(
              child: orders == null
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator if drivers data is null
                  : ListView.builder(
                      itemCount: orders!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            OrderCard(
                              orderTime: orders![index].orderTime,
                              orderLocation: orders![index].orderLocation,
                              status: orders![index].status,
                              // isTaken: orders![index].isTaken,
                              driverInfo: orders![index].driverInfo,
                              storeInfo: orders![index].storeInfo,
                              press: () {
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => DriverCardWindow(
                                //     driverName: drivers![index].name,
                                //     driverImage: drivers![index].driverImage,
                                //     driverMobile: drivers![index].phoneNumber,
                                //     driverID: drivers![index].driverID,
                                //   ),
                                // );
                              },
                              onChangeStatus: () {
                                _changeOrderStatus(index);
                              },
                              onCancel: () {
                                _removeOrder(index);
                              },
                            ),
                            const SizedBox(
                                height: 20), // Add space between each section
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

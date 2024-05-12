import 'package:flutter/material.dart';
import 'package:pixandrix/drivers/driver_card_window.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/orders/order_card_windows.dart';
import 'package:pixandrix/orders/order_form.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'package:pixandrix/orders/order_card_owners.dart';

class OwnersHomePage extends StatefulWidget {
  final OwnerData? ownerInfo;
  const OwnersHomePage({super.key, this.ownerInfo});

  @override
  _OwnersHomePageState createState() => _OwnersHomePageState();
}

class _OwnersHomePageState extends State<OwnersHomePage> {
  late OwnerData? ownerInfo;
  List<OrderData>? orders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    ownerInfo = widget.ownerInfo;
  }

  Future<void> _removeOrder(int index) async {
    // Remove the driver at the specified index from the list
    if (index >= 0 && index < orders!.length) {
      final orderToRemove = orders![index];
      await FirebaseOperations.removeOrder(orderToRemove.orderID);
      _loadOrders(); // Refresh the drivers list after removing the driver
    }
  }

  Future<void> _loadOrders() async {
    // Fetch drivers data and cast it to a List<DriverData>
    final fetchedOrders = await FirebaseOperations.getOrders();
    orders = fetchedOrders.cast<OrderData>();

    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated drivers data
    }
  }

  Future<void> _changeOrderStatus(
    int index,
  ) async {
    // Remove the driver at the specified index from the list
    final orderToChange = orders![index].orderID;
    final driver = ownerInfo?.name;
    if (orders![index].status == 'OrderStatus.pending') {
      if (index >= 0 && index < orders!.length) {
        await FirebaseOperations.changeOrderStatus(
            'OrderStatus.inProgress', orderToChange);
        await FirebaseOperations.changeDriverName(driver!, orderToChange);
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
      appBar: AppBar(
        title: Center(
          child: Text(ownerInfo?.name ?? 'Owner Name'),
        ), // Use owner's name or a default value
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(ownerInfo?.ownerImage ??
                ''), // Use owner's image or a default image URL
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
                    MaterialPageRoute(builder: (context) => const FirstPage()),
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: CustomButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderForm(ownerInfo: widget.ownerInfo),
                      ),
                    );
                  },
                  text: 'Request a Driver',
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: orders == null
                    ? const Center(
                        child:
                            CircularProgressIndicator()) // Show loading indicator if drivers data is null
                    : ListView.builder(
                        itemCount: orders!.length,
                        itemBuilder: (context, index) {
                          if (orders![index].storeInfo == ownerInfo?.name) {
                            return Column(
                              children: [
                                OrderCardOwners(
                                  orderTime: orders![index].orderTime,
                                  orderLocation: orders![index].orderLocation,
                                  status: orders![index].status,
                                  // isTaken: orders![index].isTaken,
                                  driverInfo: orders![index].driverInfo,
                                  storeInfo: orders![index].storeInfo,
                                  press: () {
                                    String orderID = orders![index].orderID;
                                    if(orderID.isEmpty){
                                      orderID = 'No driver';
                                    }
                                    showDialog(
                                      context: context,
                                      builder: (context) => OrderCardWindow(
                                        driverName: orders![index].driverInfo,
                                        orderID: orderID
                                      ),
                                    );
                                  },
                                  onCancel: () {
                                    _removeOrder(index);
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
    );
  }
}

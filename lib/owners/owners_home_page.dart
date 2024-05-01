import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/order_form.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'package:pixandrix/widgets/order_card_owners.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ownerInfo?.name ??
            'Owner Name'), // Use owner's name or a default value
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
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
                            OrderCardOwners(
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
                              onCancel: () {
                                _removeOrder(index);
                              },
                            ),
                            const SizedBox(height: 20),
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

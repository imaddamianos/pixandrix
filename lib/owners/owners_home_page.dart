import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/orders/order_card_owners_windows.dart';
import 'package:pixandrix/orders/order_form.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'package:pixandrix/orders/order_card_owners.dart';

final _secureStorage = SecureStorage();

class OwnersHomePage extends StatefulWidget {
  final OwnerData? ownerInfo;
  const OwnersHomePage({super.key, this.ownerInfo});

  @override
  _OwnersHomePageState createState() => _OwnersHomePageState();
}

class _OwnersHomePageState extends State<OwnersHomePage> {
  late OwnerData? ownerInfo;
  List<OrderData>? orders;
  late bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    ownerInfo = widget.ownerInfo;
  }

  Future<void> _removeOrder(int index) async {
    if (index >= 0 && index < orders!.length) {
      final orderToRemove = orders![index];
      await FirebaseOperations.removeOrder(orderToRemove.orderID);
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    final savedOwner = await _secureStorage.getOnwer();
    final fetchedOrders = await FirebaseOperations.getOrders();
    orders = fetchedOrders
        .where((order) => order.storeInfo == ownerInfo?.name)
        .toList();
    orders!.sort((a, b) => a.orderTime.compareTo(b.orderTime));

    if (orders!.isNotEmpty) {
      setState(() {
        isButtonDisabled = _shouldDisableButton();
      });
    }
  }

  bool _shouldDisableButton() {
    final latestOrderTime = orders!.last.orderTime.toDate();
    final timeDifference = DateTime.now().difference(latestOrderTime);
    if (timeDifference.inMinutes < -5) {
      return true;
    } else {
      return false;
    }
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
          child: Text(ownerInfo?.name ?? 'Owner Name'),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(ownerInfo?.ownerImage ?? ''),
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
                  onPressed: isButtonDisabled
                      ? null
                      : () {
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
              const SizedBox(height: 10),
              Text(
                'Orders: ${orders?.length ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: orders == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
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
                                  driverInfo: orders![index].driverInfo,
                                  storeInfo: orders![index].storeInfo,
                                  orderID: orders![index].orderID,
                                  press: () {
                                    String orderID = orders![index].orderID;
                                    String orderLocation =
                                        orders![index].orderLocation;
                                    if (orderID.isEmpty) {
                                      orderID = 'No driver';
                                    }
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          OrderCardOwnersWindow(
                                        driverName: orders![index].driverInfo,
                                        orderID: orderID,
                                        orderLocation: orderLocation,
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
                            return const SizedBox.shrink();
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

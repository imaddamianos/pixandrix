import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/notification_calls.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/orders/order_card_owners.dart';
import 'package:pixandrix/orders/order_card_owners_windows.dart';
import 'package:pixandrix/orders/order_form.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';

final _secureStorage = SecureStorage();

class OwnersHomePage extends StatefulWidget {
  final OwnerData? ownerInfo;
  const OwnersHomePage({super.key, this.ownerInfo});

  @override
  _OwnersHomePageState createState() => _OwnersHomePageState();
}

class _OwnersHomePageState extends State<OwnersHomePage> with RouteAware, WidgetsBindingObserver {
  OwnerData? ownerInfo;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeNotifications(context, 'owner');
    loadOwnerInfo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadOwnerInfo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> loadOwnerInfo() async {
    ownerInfo = await _secureStorage.getOwnerInfo();
    subscribeToOrderStatusChanges(ownerInfo!.name);
    setState(() {});
  }

  bool _shouldDisableButton(List<OrderData> orders) {
    if (orders.isEmpty) return false;

    final latestOrder = orders.last;
    final lastOrderTimeUpdate = latestOrder.lastOrderTimeUpdate.toDate();
    final adjustedLastOrderTimeUpdate = lastOrderTimeUpdate.add(const Duration(minutes: 10));
    final currentTime = DateTime.now();
    final status = latestOrder.status;
    if (currentTime.isBefore(adjustedLastOrderTimeUpdate) && status == 'OrderStatus.pending') {
      return true;
    } else if ((currentTime.isAfter(adjustedLastOrderTimeUpdate) && status == 'OrderStatus.inProgress')) {
      return false;
    }
    return false;
  }

  Future<void> _removeOrder(String orderId, String status) async {
    if (status == 'OrderStatus.pending') {
      showAlertChangeProgress(
        context,
        'Remove Order',
        "Are you sure you want to remove and cancel the order?",
        'OrderStatus.remove',
        orderId,
        '',
        () => setState(() {}),
      );
    } else if (status == 'OrderStatus.inProgress') {
      showAlertDialog(context, 'Order in Progress', 'You cannot delete the Order!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
                  onPressed: () async {
                    await loadOwnerInfo();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    showAlertWithDestination(context, 'Log Out', 'Are you sure you want to Log out?', const FirstPage());
                  },
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
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

                // Filter orders to include only those related to the owner's store
                final ownerOrders = orders.where((order) => order.storeInfo == ownerInfo?.name).toList();

                // Sort orders by status
                ownerOrders.sort((a, b) {
                  const statusOrder = {
                    'OrderStatus.pending': 0,
                    'OrderStatus.inProgress': 1,
                    'OrderStatus.delivered': 2,
                  };
                  return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
                });

                isButtonDisabled = _shouldDisableButton(ownerOrders);

                return Column(
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
                                    builder: (context) => OrderForm(ownerInfo: ownerInfo),
                                  ),
                                );
                              },
                        text: 'Request a Driver',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Orders: ${ownerOrders.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ownerOrders.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              OrderCardOwners(
                                orderTime: ownerOrders[index].orderTime,
                                orderLocation: ownerOrders[index].orderLocation,
                                status: ownerOrders[index].status,
                                driverInfo: ownerOrders[index].driverInfo,
                                storeInfo: ownerOrders[index].storeInfo,
                                orderID: ownerOrders[index].orderID,
                                lastOrderTimeUpdate: ownerOrders[index].lastOrderTimeUpdate,
                                press: () {
                                  String orderID = ownerOrders[index].orderID;
                                  String orderLocation = ownerOrders[index].orderLocation;
                                  if (orderID.isEmpty) {
                                    orderID = 'No driver';
                                  }
                                  subscribeToChangedOrders(ownerInfo!.name, ownerOrders[index].orderID);
                                  showDialog(
                                    context: context,
                                    builder: (context) => OrderCardOwnersWindow(
                                      driverName: ownerOrders[index].driverInfo,
                                      orderID: orderID,
                                      orderLocation: orderLocation,
                                    ),
                                  );
                                },
                                onCancel: () {
                                  _removeOrder(ownerOrders[index].orderID, ownerOrders[index].status);
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

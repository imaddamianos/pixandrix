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
  List<OrderData>? orders;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeNotifications(context, 'owner');
    loadOwnerInfo().then((_) {
      loadOrders();
    });
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
  }

Future<void> loadOrders() async {
  if (ownerInfo != null) {
    final fetchedOrders = await FirebaseOperations.getOrders();

    // Sort fetched orders by status
    fetchedOrders.sort((a, b) {
      const statusOrder = {
        'OrderStatus.pending': 0,
        'OrderStatus.inProgress': 1,
        'OrderStatus.delivered': 2,
      };
      return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
    });

    // Filter orders to include only those related to the owner's store
    orders = fetchedOrders.where((order) => order.storeInfo == ownerInfo?.name).toList();

    setState(() {
      isButtonDisabled = _shouldDisableButton();
    });
  }
}


  bool _shouldDisableButton() {
    if (orders == null || orders!.isEmpty) return false;

    final latestOrder = orders!.last;
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

  Future<void> _removeOrder(int index) async {
    if (index >= 0 && index < orders!.length) {
      final orderToRemove = orders![index];
      final status = orders![index].status;
      if (status == 'OrderStatus.pending') {
        if (index >= 0 && index < orders!.length) {
          showAlertChangeProgress(
            context,
            'Remove Order',
            "Are you sure you want to remove and cancel the order?",
            'OrderStatus.remove',
            orderToRemove.orderID,
            '',
            loadOrders,
          );
        }
      } else if (status == 'OrderStatus.inProgress') {
        showAlertDialog(context, 'Order in Progress', 'You cannot delete the Order!');
      }
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
                    await loadOrders();
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
            onRefresh: loadOrders,
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
                                builder: (context) => OrderForm(ownerInfo: ownerInfo),
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
                            return Column(
                              children: [
                                OrderCardOwners(
                                  orderTime: orders![index].orderTime,
                                  orderLocation: orders![index].orderLocation,
                                  status: orders![index].status,
                                  driverInfo: orders![index].driverInfo,
                                  storeInfo: orders![index].storeInfo,
                                  orderID: orders![index].orderID,
                                  lastOrderTimeUpdate: orders![index].lastOrderTimeUpdate,
                                  press: () {
                                    String orderID = orders![index].orderID;
                                    String orderLocation = orders![index].orderLocation;
                                    if (orderID.isEmpty) {
                                      orderID = 'No driver';
                                    }
                                    subscribeToChangedOrders(ownerInfo!.name, orders![index].orderID);
                                    showDialog(
                                      context: context,
                                      builder: (context) => OrderCardOwnersWindow(
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

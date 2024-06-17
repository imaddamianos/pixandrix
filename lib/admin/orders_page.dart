import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/helpers/notification_bell.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/orders/order_card.dart';
import 'package:pixandrix/orders/order_card_windows.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';

final _secureStorage = SecureStorage();

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedSortOption = 'Last Order';
  List<OrderData> _orders = [];

  @override
  void initState() {
    super.initState();
    _secureStorage.setAutoLoginStatus(false, 'admin');
  }

  Future<void> _removeOrder(String orderId) async {
    showAlertChangeProgress(
      context,
      'Remove Order',
      "Are you sure you want to remove and cancel the order?",
      'OrderStatus.remove',
      orderId,
      '',
      () => setState(() {}),
    );
  }

  Future<void> _resetOrderNumber() async {
    try {
      int currentOrderNumber = 0;
      await FirebaseFirestore.instance
          .collection('ordersNumber')
          .doc('orderNumber')
          .set({'value': currentOrderNumber});
    } catch (error) {
      print('Error resetting order number: $error');
      throw error;
    }
  }

  List<OrderData> _sortOrders(List<OrderData> orders) {
    if (_selectedSortOption == 'Last Order') {
      orders.sort((a, b) => b.lastOrderTimeUpdate.compareTo(a.lastOrderTimeUpdate));
    } else if (_selectedSortOption == 'Status') {
      const statusOrder = {
        'OrderStatus.pending': 0,
        'OrderStatus.inProgress': 1,
        'OrderStatus.delivered': 2,
      };
      orders.sort((a, b) => statusOrder[a.status]!.compareTo(statusOrder[b.status]!));
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomButton(
                text: 'Reset orders',
                onPressed: () {
                  showAlertWithFunction(
                    context,
                    'Reset Orders Number',
                    'Are you sure you want to reset the order number?',
                    _resetOrderNumber,
                  );
                },
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No orders available'));
                  }

                  _orders = snapshot.data!.docs.map((doc) {
                    return OrderData.fromDocument(doc);
                  }).toList();

                  final sortedOrders = _sortOrders(_orders);

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orders: ${sortedOrders.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Sort by:',),
                            const SizedBox(width: 10),
                            DropdownButton<String>(
                              value: _selectedSortOption,
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.white),
                              items: <String>['Last Order', 'Status']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSortOption = newValue!;
                                  _sortOrders(_orders);
                                });
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: sortedOrders.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  OrderCard(
                                    orderTime: sortedOrders[index].orderTime,
                                    orderLocation: sortedOrders[index].orderLocation,
                                    status: sortedOrders[index].status,
                                    driverInfo: sortedOrders[index].driverInfo,
                                    storeInfo: sortedOrders[index].storeInfo,
                                    lastOrderTimeUpdate: sortedOrders[index].lastOrderTimeUpdate,
                                    press: () {
                                      String orderID = sortedOrders[index].orderID;
                                      showDialog(
                                        context: context,
                                        builder: (context) => OrderCardWindow(
                                          driverName: sortedOrders[index].driverInfo,
                                          orderID: orderID,
                                          ownerName: sortedOrders[index].storeInfo,
                                          orderLocation: sortedOrders[index].orderLocation,
                                          lastOrderTimeUpdate: sortedOrders[index].lastOrderTimeUpdate,
                                        ),
                                      );
                                    },
                                    onChangeStatus: () {},
                                    onCancel: () {
                                      _removeOrder(sortedOrders[index].orderID);
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

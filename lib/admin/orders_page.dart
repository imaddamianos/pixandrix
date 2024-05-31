import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/orders/order_card.dart';
import 'package:pixandrix/orders/order_card_windows.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<OrderData>? orders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final fetchedOrders = await FirebaseOperations.getOrders();
    setState(() {
      orders = fetchedOrders.cast<OrderData>();
    });
  }

  Future<void> _removeOrder(int index) async {
    if (index >= 0 && index < orders!.length) {
      final orderToRemove = orders![index];
             showAlertChangeProgress(
            context,
            'Remove Order',
            "Are you sure you want to remove and cancel the order?",
            'OrderStatus.remove',
            orderToRemove.orderID,
            '',
            _loadOrders);
    }
  }

  Future<void> _resetOrderNumber() async {
  try {
    int currentOrderNumber = 0;
    // Update the order number in Firestore
    await FirebaseFirestore.instance.collection('ordersNumber').doc('orderNumber').set({'value': currentOrderNumber});

  } catch (error) {
    print('Error getting next order number: $error');
    // You can handle the error here as needed
    throw error;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomButton(
              text: 'Reset orders',
              onPressed: (){
                showAlertWithFunction(context, 'Reset Orders Number', 'Are you sure you want to reset the order number', _resetOrderNumber());
              },
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
                              OrderCard(
                                orderTime: orders![index].orderTime,
                                orderLocation: orders![index].orderLocation,
                                status: orders![index].status,
                                driverInfo: orders![index].driverInfo,
                                storeInfo: orders![index].storeInfo,
                                lastOrderTimeUpdate: orders![index].lastOrderTimeUpdate,
                                press: () {
                                   String orderID = orders![index].orderID;
                                    showDialog(
                                      context: context,
                                      builder: (context) => OrderCardWindow(
                                        driverName: orders![index].driverInfo,
                                        orderID: orderID,
                                        ownerName: orders![index].storeInfo,
                                        orderLocation: orders![index].orderLocation,
                                        lastOrderTimeUpdate :orders![index].lastOrderTimeUpdate,
                                      ),
                                    );
                                },
                                onChangeStatus: () {
                                 
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
    );
  }
}

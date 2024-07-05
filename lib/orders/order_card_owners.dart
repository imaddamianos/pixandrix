import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/helpers/notification_bell.dart';
import 'package:pixandrix/helpers/order_status_utils.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/owners/owners_home_page.dart';
import 'package:timer_builder/timer_builder.dart';

class OrderCardOwners extends StatelessWidget {
  const OrderCardOwners({
    super.key,
    required this.orderTime,
    required this.orderLocation,
    required this.status,
    required this.orderID,
    required this.driverInfo,
    required this.storeInfo,
    required this.lastOrderTimeUpdate,
    required this.press,
    required this.onCancel,
    required this.orders,
  });

  final String driverInfo, orderLocation, storeInfo;
  final String status;
  final String orderID;
  final Timestamp orderTime, lastOrderTimeUpdate;
  final GestureTapCallback press;
  final VoidCallback onCancel;
  final List<OrderData> orders;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> statusInfo = getStatusInfo(status, 'owner');
    DateTime now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: press,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 20,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        orderID,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderLocation,
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 4),
                       TimerBuilder.periodic(
                            const Duration(seconds: 1),
                            builder: (context) {
                              Duration timeLeft =
                                  orderTime.toDate().difference(now);
                          if (status == 'OrderStatus.pending') {
                            return Text(
                              'Time: ${_formatDuration(timeLeft, orderTime, lastOrderTimeUpdate, orderID)}',
                              style: const TextStyle(color: Colors.white),
                            );
                          } else {
                            return const Text('');
                          }
                        },
                          ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 184, 184, 183),
                        Colors.transparent,
                        Color.fromARGB(200, 184, 184, 183),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: TextButton(
                    onPressed: null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Column(

                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo['iconData'],
                          color: statusInfo['iconColor'],
                        ),
                        Text(
                          statusInfo['statusText'],
                          style: TextStyle(
                            color: statusInfo['iconColor'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 String _formatDuration(Duration duration, Timestamp orderTimestamp, Timestamp lastOrderTimeUpdate, String orderId) {
  DateTime now = DateTime.now();
  DateTime orderTime = orderTimestamp.toDate();
  DateTime lastOrderTime = lastOrderTimeUpdate.toDate();

  Duration timeLeft = orderTime.difference(now);
  Duration timeSinceLastUpdate = now.difference(lastOrderTime);
  var notificationSent = false;

  if (timeLeft.isNegative) {
    return 'Expired';
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitHours = twoDigits(timeLeft.inHours.remainder(24));
  String twoDigitMinutes = twoDigits(timeLeft.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(timeLeft.inSeconds.remainder(60));

  if (timeSinceLastUpdate.inMinutes >= 5) {
    FirebaseOperations.changeOrderTaken(orderId);
    requestDriverCheck.shouldDisableButton(orders);

    if (notificationSent == false){
      notificationService.subscribeToRequestButton(orderId);
      notificationSent = true;
    }
    return '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds Check order';
  } else {
    return '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
  }
}
}

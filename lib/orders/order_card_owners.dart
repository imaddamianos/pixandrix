import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixandrix/helpers/order_status_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
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
    required this.press,
    required this.onCancel,
  });

  final String driverInfo, orderLocation, storeInfo;
  final String status;
  final String orderID;
  final Timestamp orderTime; // Change the type to Timestamp
  final GestureTapCallback press;
  final VoidCallback onCancel;

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
                              return Text(
                                'Time: ${_formatDuration(timeLeft, orderTime)}',
                                style: const TextStyle(color: Colors.white),
                              );
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
 String _formatDuration(Duration duration, Timestamp orderTimestamp) {
  DateTime now = DateTime.now().toLocal(); // Convert to local time
  DateTime orderTime = orderTimestamp.toDate().toLocal(); // Convert to local time
  Duration timeDifference = orderTime.difference(now);

  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitHours = twoDigits(timeDifference.inHours.remainder(24));
  String twoDigitMinutes = twoDigits(timeDifference.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(timeDifference.inSeconds.remainder(60));

  if (timeDifference.isNegative) {
    return 'Expired';
  } else if (timeDifference.inMinutes <= 10) {
    return 'Check order $twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
  } else {
    return '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
  }
}
}

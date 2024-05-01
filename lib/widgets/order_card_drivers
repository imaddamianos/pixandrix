import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixandrix/helpers/order_status_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderCardDrivers extends StatelessWidget {
  const OrderCardDrivers({
    super.key,
    required this.orderTime,
    required this.orderLocation,
    required this.status,
    // required this.isTaken,
    required this.driverInfo,
    required this.storeInfo,
    required this.press,
    required this.onChangeStatus,
  });

  final String driverInfo, orderLocation, storeInfo;
  final String status;
  // final bool isTaken;
  final Timestamp orderTime; // Change the type to Timestamp
  final GestureTapCallback press;
  final VoidCallback onChangeStatus;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> statusInfo = getStatusInfo(status);
    DateTime dateTime = orderTime.toDate(); // Convert Timestamp to DateTime
    String timeAgo = timeago.format(dateTime, locale: 'en_short');

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
                        storeInfo,
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
                      Text(
                        '$timeAgo ago',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   'Is Taken: $isTaken',
                      //   style: const TextStyle(color: Colors.white),
                      // ),
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
                  child: IconButton(
                    icon: Icon(
                      statusInfo['iconData'],
                      color: statusInfo['iconColor'],
                    ),
                    onPressed: onChangeStatus,
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

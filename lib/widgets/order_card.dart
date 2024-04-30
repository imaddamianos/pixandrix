import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderCard extends StatelessWidget {
  const OrderCard({
    Key? key,
    required this.orderTime,
    required this.orderLocation,
    // required this.status,
    // required this.isTaken,
    required this.driverInfo,
    required this.storeInfo,
    required this.press,
    required this.onDelete,
  }) : super(key: key);

  final String driverInfo, orderLocation, storeInfo;
  // final OrderStatus status;
  // final bool isTaken;
  final Timestamp orderTime; // Change the type to Timestamp
  final GestureTapCallback press;
  final VoidCallback onDelete;

  @override
  @override
  Widget build(BuildContext context) {
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
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.circle),
                      color: const Color.fromARGB(255, 255, 247, 0),
                      onPressed: onDelete,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: TextButton(
                        onPressed: onDelete,
                        child: const Text(
                          'Cancel',
                          style:
                              TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
                        ),
                      ),
                    ),
                  ],
                ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
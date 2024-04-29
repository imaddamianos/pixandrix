

import 'package:flutter/material.dart';
import 'package:pixandrix/models/order_model.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    // required this.orderTime,
    required this.orderLocation,
    // required this.status,
    // required this.isTaken,
    required this.driverInfo,
    required this.storeInfo,
    required this.press,
    required this.onDelete,
  });

  final String driverInfo, orderLocation, storeInfo;
  // final String status;
  // final bool isTaken;
  // final DateTime orderTime;
  final GestureTapCallback press;
  final VoidCallback onDelete;

  @override
  @override
Widget build(BuildContext context) {
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
                      'Store: $storeInfo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: $orderLocation',
                      style: const TextStyle(color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   'Order Time: ${orderTime.toString()}',
                    //   style: const TextStyle(color: Colors.white),
                    // ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   'Status: $status',
                    //   style: const TextStyle(color: Colors.white),
                    // ),
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
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                    onPressed: onDelete,
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

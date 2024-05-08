import 'package:flutter/material.dart';

class OrderCardWindow extends StatelessWidget {
  final String driverName;
  final String orderID;

  const OrderCardWindow({
    super.key,
    required this.driverName,
    required this.orderID,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(
                orderID,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                driverName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

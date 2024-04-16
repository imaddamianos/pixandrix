import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   title: const Text('Orders Page'),
      // ),
      body: Center(
        child: Text(
          'Orders Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

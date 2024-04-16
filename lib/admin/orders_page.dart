import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Page'),
      ),
      body: const Center(
        child: Text(
          'Orders Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

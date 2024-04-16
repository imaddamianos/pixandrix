import 'package:flutter/material.dart';

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers Page'),
      ),
      body: const Center(
        child: Text(
          'Drivers Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

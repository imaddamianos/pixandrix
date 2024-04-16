import 'package:flutter/material.dart';

class OwnersPage extends StatelessWidget {
  const OwnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   title: const Text('Owners Page'),
      // ),
      body: Center(
        child: Text(
          'Owners Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

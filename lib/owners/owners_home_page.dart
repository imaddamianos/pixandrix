import 'package:flutter/material.dart';

class OwnersHomePage extends StatelessWidget {
  const OwnersHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner\'s Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Handle button press, like requesting a driver
            // You can navigate to a new page or perform any action here
          },
          child: const Text('Request a Driver'),
        ),
      ),
    );
  }
}

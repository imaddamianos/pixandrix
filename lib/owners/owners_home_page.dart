import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';

class OwnersHomePage extends StatelessWidget {
  const OwnersHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pix and Rix'),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Handle notifications action
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FirstPage()),
                  );
                },
              ),
            ],
          ),
        ],
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

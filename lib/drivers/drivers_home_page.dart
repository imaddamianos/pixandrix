import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';

class DriversHomePage extends StatelessWidget {
  const DriversHomePage({Key? key}) : super(key: key);

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
      body: const Center(
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';

class DriversHomePage extends StatefulWidget {
  const DriversHomePage({Key? key, this.driverInfo}) : super(key: key);
  final Map<String, dynamic>? driverInfo;
  
  @override
  _DriversHomePageState createState() => _DriversHomePageState();
}

class _DriversHomePageState extends State<DriversHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.driverInfo?['name']),
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

import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/models/driver_model.dart';

class DriversHomePage extends StatefulWidget {
  final DriverData? driverInfo;
  const DriversHomePage({super.key, this.driverInfo});
  
  @override
  _DriversHomePageState createState() => _DriversHomePageState();
}

class _DriversHomePageState extends State<DriversHomePage> {
late DriverData? driverInfo;

  @override
  void initState() {
    super.initState();
    driverInfo = widget.driverInfo; // Initialize ownerInfo in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(driverInfo!.name),
        leading: CircleAvatar( // Display owner's image in the leading of app bar
        backgroundImage: NetworkImage(driverInfo!.driverImage), // Assuming image is a URL
      ),
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

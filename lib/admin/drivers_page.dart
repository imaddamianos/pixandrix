import 'package:flutter/material.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  void addDriver() {
    // Add your logic to add a driver here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Add space on all sides
        child: AddButton(text: 'Add Owner', onPressed: addDriver),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pixandrix/admin/add%20drivers/add_driver.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Add space on all sides
        child: AddButton(text: 'Add Driver', onPressed: (){
          Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AddDriverPage()),
      );
        }),
      ),
    );
  }
}

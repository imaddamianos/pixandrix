import 'package:flutter/material.dart';
import 'package:pixandrix/admin/add%20owners/add_owner.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';

class OwnersPage extends StatelessWidget {
  const OwnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Add space on all sides
        child: AddButton(text: 'Add Owner', onPressed: (){
          Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AddOwnerPage()),
      );
        }),
      ),
    );
  }
}

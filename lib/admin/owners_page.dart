import 'package:flutter/material.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';

class OwnersPage extends StatelessWidget {
  const OwnersPage({super.key});

  void addOwner() {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Add space on all sides
        child: AddButton(text: 'Add Driver', onPressed: addOwner),
      ),
    );
  }
}

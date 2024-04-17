import 'package:flutter/material.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';

class OwnersPage extends StatelessWidget {
  const OwnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: Center(
        child: Text(
          'Owners Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'admin_panel.dart';

class AdminPassPage extends StatefulWidget {
  const AdminPassPage({super.key});

  @override
  _AdminPassPageState createState() => _AdminPassPageState();
}

class _AdminPassPageState extends State<AdminPassPage> {
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _checkPassword() {
    String enteredPassword = _passwordController.text.trim();
    if (enteredPassword == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPanelPage()),
      );
    } else {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
          text: 'Continue',
          onPressed: _checkPassword,
        ),
          ],
        ),
      ),
    );
  }
}

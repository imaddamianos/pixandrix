import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/helpers/loader.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'admin_panel.dart';

final _secureStorage = SecureStorage();

class AdminPassPage extends StatefulWidget {
  const AdminPassPage({super.key});

  @override
  _AdminPassPageState createState() => _AdminPassPageState();
}

class _AdminPassPageState extends State<AdminPassPage> {
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  final GlobalLoader _globalLoader = GlobalLoader();
  bool? remember = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkName);
    _loadSavedCredentials();
  }

  void _checkPassword() {
    _globalLoader.showLoader(context);
    String enteredPassword = _passwordController.text.trim();
    if (enteredPassword == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPanelPage()),
      );
      _globalLoader.hideLoader();
      _secureStorage.saveAdmin(enteredPassword);
    } else {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
        _globalLoader.hideLoader();
      });
    }
  }

  void _checkName() async {
    String enteredName = _passwordController.text.trim();
    bool available =
        await FirebaseOperations.checkDriverNameExists(enteredName);
    setState(() {
    });
  }

  Future<void> _loadSavedCredentials() async {
    final savedPass = await _secureStorage.getAdminPassword();
    if (savedPass != null) {
      _passwordController.text = savedPass;
      setState(() {
        remember = true; // Set _saveCredentials to true if password is saved
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
            Checkbox(
              activeColor: const Color.fromARGB(255, 255, 0, 0),
              value: remember,
              onChanged: (value) {
                setState(() {
                  remember = value!;
                });
              },
            ),
            const Text('Save Credentials'),
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

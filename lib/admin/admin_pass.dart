import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
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
    _loadSavedCredentials();
  }

  Future<void> _checkPassword() async {
    _globalLoader.showLoader(context);
     String enteredPassword = _passwordController.text.trim();
    bool available =
        await FirebaseOperations.checkAdminPass(enteredPassword);
    if (available) {
      FirebaseOperations.addTokentoUsers('', '');
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
    return WillPopScope(
      // This widget will intercept the back button press
      onWillPop: () async {
        // Return false to prevent the back button action
        return false;
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FirstPage()),
              );
            },
          ),
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
    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';

class StoreLoginPage extends StatefulWidget {
  const StoreLoginPage({super.key});

  @override
  _StoreLoginPageState createState() => _StoreLoginPageState();
}

class _StoreLoginPageState extends State<StoreLoginPage> {
  bool _saveCredentials = false;
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _restaurantNameAvailable = false;

  @override
  void initState() {
    super.initState();
    _restaurantNameController.addListener(_checkName);
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    super.dispose();
  }

  void _checkName() async {
    String enteredName = _restaurantNameController.text.trim();
    if (enteredName.isEmpty) {
      setState(() {
        _restaurantNameAvailable = false;
        _errorMessage = '';
      });
      return;
    }
    bool available = await FirebaseOperations.checkRestaurantNameExists(enteredName);
    setState(() {
      _restaurantNameAvailable = available;
      _errorMessage = available ? '' : 'Restaurant name not found.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Log in to enter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red, // Example color, replace with your desired color
                // Add more text style properties as needed
              ),
            ),
            const SizedBox(height: 70),
            TextField(
              controller: _restaurantNameController,
              onChanged: (_) => _checkName(),
              decoration: InputDecoration(
                labelText: 'Restaurant Name',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                suffixIcon: _restaurantNameAvailable
                    ? Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Checkbox(
                  value: _saveCredentials,
                  onChanged: (value) {
                    setState(() {
                      _saveCredentials = value!;
                    });
                  },
                ),
                const Text('Save Credentials'),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String restaurantName = _restaurantNameController.text;
                String password = _passwordController.text;
                // Use the credentials as needed (login, save to storage, etc.)
                // For example:
                if (_saveCredentials) {
                  // Save the credentials to storage
                }
                // Perform login or navigate to the next screen
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

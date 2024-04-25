import 'package:flutter/material.dart';
import 'package:pixandrix/admin/admin_pass.dart';
import 'package:pixandrix/drivers/drivers_login.dart';
import 'package:pixandrix/owners/owners_login.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pix and Rix'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Who are you?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors
                    .red, // Example color, replace with your desired color
                // Add more text style properties as needed
              ),
            ),
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DriversLoginPage()),
                      );
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/driver_icon.png',
                          width: 100,
                          height: 100,
                        ),
                        // const SizedBox(height: 8),
                        // const Text('Drivers'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 70),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StoreLoginPage()),
                      );
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/stores_icon.png',
                          width: 100,
                          height: 100,
                        ),
                        // const SizedBox(height: 8),
                        // const Text('Store'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminPassPage()),
                );
              },
              child: const Text(
                'Admin Panel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pixandrix/admin_pass.dart';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              SizedBox(
              width: 120,
              height: 120,
              child: ElevatedButton(
                onPressed: () {
                  // Handle driver button press
                  // Navigate to driver login/register page
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/driver_icon.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text('Drivers'),
                  ],
                ),
              ),
            ),
                const SizedBox(width: 20),
               SizedBox(
              width: 120,
              height: 120,
              child: ElevatedButton(
                onPressed: () {
                  // Handle driver button press
                  // Navigate to driver login/register page
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/stores_icon.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text('Store'),
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
        MaterialPageRoute(builder: (context) => const  AdminPassPage()),
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
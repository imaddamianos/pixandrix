import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart'; // Import your FirstPage widget

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToFirstPage();
  }

  Future<void> _navigateToFirstPage() async {
    // Add a delay to simulate the splash screen display duration
    await Future.delayed(const Duration(seconds: 2)); // Adjust duration as needed

    // Navigate to FirstPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirstPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/pimadoBackground.jpeg'), // Adjust the path as per your image file
      ),
    );
  }
}

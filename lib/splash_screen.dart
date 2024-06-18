import 'package:flutter/material.dart';
import 'package:pixandrix/admin/admin_panel.dart';
import 'package:pixandrix/drivers/drivers_home_page.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/owners/owners_home_page.dart';

final _secureStorage = SecureStorage();

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

  Future<void> autoLogin(BuildContext context) async {
    String? isLoggedOut = await _secureStorage.getLogoutStatus();
    String? savedRole = await _secureStorage.getAutoLoginRole();

    if (isLoggedOut == 'true') {
      // Navigate to SplashScreen if logged out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FirstPage()),
      );
    } else {
      if (savedRole == 'driver') {
        // Navigate to HomeScreen if the driver password is saved
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriversHomePage()),
        );
      } else if (savedRole == 'owner') {
        // Handle case where password is not saved (e.g., show login screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OwnersHomePage()),
        );
      }else if (savedRole == 'admin') {
        // Handle case where password is not saved (e.g., show login screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanelPage()),
        );
      }else{
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FirstPage()),
      );
      }
    }
  }

  Future<void> _navigateToFirstPage() async {
    // Add a delay to simulate the splash screen display duration
    await Future.delayed(const Duration(seconds: 2)); // Adjust duration as needed
autoLogin(context);
    // Navigate to FirstPage
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const FirstPage()),
    // );
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

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/admin/admin_pass.dart';
import 'package:pixandrix/drivers/drivers_login.dart';
import 'package:pixandrix/helpers/permission_handler.dart';
import 'package:pixandrix/owners/owners_login.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});
@override
  _FirstPageState createState() => _FirstPageState();
}
class _FirstPageState extends State<FirstPage> {

   @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    getLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
    onWillPop: () async {
      return false;
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Pimado'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/pimadoBackground.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Choose your Role',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255), // Example color, replace with your desired color
                  // Add more text style properties as needed
                ),
              ),
              const SizedBox(height: 50),
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
      ),
    ),
  );
}
}

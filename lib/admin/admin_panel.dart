import 'package:flutter/material.dart';
import 'package:pixandrix/admin/drivers_page.dart';
import 'package:pixandrix/admin/orders_page.dart';
import 'package:pixandrix/admin/owners_page.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const OwnersPage(),
    const DriversPage(),
    const OrdersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // This widget will intercept the back button press
      onWillPop: () async {
        // Return false to prevent the back button action
        return false;
      },
      child:  Scaffold(
      appBar: AppBar(
        title: const Text('Pimado'),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Handle notifications action
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                 onPressed: () {
                    showAlertWithDestination(context, 'Log Out', 'Are you sure you want to Log out?', const FirstPage());
                  },
              ),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255), // Change the selected item color
        unselectedItemColor: const Color.fromARGB(255, 153, 153, 153), // Change the unselected item color
        selectedLabelStyle: const TextStyle(color: Color.fromARGB(101, 255, 0, 0)), // Change the selected label color
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        backgroundColor: Colors.red,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Owners',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Drivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      ),
    );
  }
}

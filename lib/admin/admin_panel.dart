import 'package:flutter/material.dart';
import 'package:pixandrix/admin/drivers_page.dart';
import 'package:pixandrix/admin/orders_page.dart';
import 'package:pixandrix/admin/owners_page.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

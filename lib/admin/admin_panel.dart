import 'package:flutter/material.dart';
import 'package:pixandrix/admin/drivers_page.dart';
import 'package:pixandrix/admin/orders_page.dart';
import 'package:pixandrix/admin/owners_page.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/helpers/notification_bell.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/settings_page.dart';

final _secureStorage = SecureStorage();

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>  with RouteAware, WidgetsBindingObserver {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    const OwnersPage(),
    const DriversPage(),
    const OrdersPage(),
  ];
 @override
  void initState() {
    super.initState();
    _secureStorage.setAutoLoginStatus(false, 'admin');
    notificationService.initializeNotifications(context, 'admin');
    notificationService.subscribeToOrderTimeExceed();
   WidgetsBinding.instance.addObserver(this);
  }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onItemTapped(2);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

   @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
             ValueListenableBuilder<int>(
                  valueListenable: notificationService.notificationCountNotifier,
                  builder: (context, notificationCount, child) {
                    return Stack(
                      children: [
                        
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            notificationService.resetNotificationCount();
                          },
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: 11,
                            top: 11,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
              IconButton(
                icon: const Icon(Icons.logout),
                 onPressed: () {
                  notificationService.stopListeningToNotifications;
                  _secureStorage.setAutoLoginStatus(true, '');
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

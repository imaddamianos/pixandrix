import 'package:flutter/material.dart';
import 'package:pixandrix/admin/add%20drivers/add_driver.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';
import 'package:pixandrix/widgets/users_card.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  _DriversPageState createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<DriverData>? drivers;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    // Fetch drivers data and cast it to a List<DriverData>
    final fetchedDrivers = await FirebaseOperations.getDrivers();
    drivers = fetchedDrivers.cast<DriverData>();

    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated drivers data
    }
  }

  Future<void> _removeDriver(int index) async {
    // Remove the driver at the specified index from the list
    if (index >= 0 && index < drivers!.length) {
      final driverToRemove = drivers![index];
      await FirebaseOperations.removeDriver(driverToRemove.name);
      _loadDrivers(); // Refresh the drivers list after removing the driver
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddButton(
              text: 'Add Drivers',
              onPressed: () async {
                // Navigate to the AddDriverPage and await the result
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddDriverPage()),
                );
                // Refresh the drivers list after adding a new driver
                _loadDrivers();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: drivers == null
                  ? const Center(child: CircularProgressIndicator()) // Show loading indicator if drivers data is null
                  : ListView.builder(
                      itemCount: drivers!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            // UsersCard(
                            //   name: drivers![index].name,
                            //   image: drivers![index].driverImage,
                            //   mobile: drivers![index].phoneNumber,
                            //   userLocation: null,
                            //   press: () {

                            //   },
                            //   onDelete: () {
                            //      _removeDriver(index);
                            //   }
                            // ),
                            const SizedBox(height: 20), // Add space between each section
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
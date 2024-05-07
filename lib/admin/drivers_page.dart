import 'package:flutter/material.dart';
import 'package:pixandrix/admin/add%20drivers/add_driver.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';
import 'package:pixandrix/drivers/driver_card.dart';
import 'package:pixandrix/drivers/driver_card_window.dart';

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
                  MaterialPageRoute(
                      builder: (context) => const AddDriverPage()),
                );
                // Refresh the drivers list after adding a new driver
                _loadDrivers();
              },
            ),
            const SizedBox(height: 10),
            Text(
                  'Owners: ${drivers?.length ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            const SizedBox(height: 10),
            Expanded(
              child: drivers == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: drivers!.length,
                      itemBuilder: (context, index) {
                        final driver = drivers![index];
                        return Column(
                          children: [
                            DriverCard(
                              name: driver.name,
                              image: driver.driverImage,
                              mobile: driver.phoneNumber,
                              isVerified: driver.verified,
                              press: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => DriverCardWindow(
                                    driverName: driver.name,
                                    driverImage: driver.driverImage,
                                    driverMobile: driver.phoneNumber,
                                    driverID: driver.driverID,
                                  ),
                                );
                              },
                              onDelete: () {
                                _removeDriver(index);
                              },
                              onToggleVerification: () async {
                                // Toggle the verified status locally
                                final newVerifiedStatus = !driver.verified;
                                // Update the verification status in Firebase
                                await FirebaseOperations
                                    .changeDriverVerification(
                                        driver.name, newVerifiedStatus);

                                // Reload the drivers list
                                _loadDrivers();
                              },
                            ),
                            const SizedBox(
                                height: 20), // Add space between each section
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

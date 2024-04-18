import 'package:flutter/material.dart';
import 'package:pixandrix/admin/add%20drivers/add_driver.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';

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
    drivers = (await FirebaseOperations.getDrivers()) as List<DriverData>?;
    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated user info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers'),
      ),
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
                // Refresh the driverss list after adding a new driver
                _loadDrivers();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildDriversTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversTable() {
    if (drivers == null) {
      return const Center(
        child: CircularProgressIndicator(), // Show loading indicator while data is being fetched
      );
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Mobile')),
      ],
      rows: drivers!.map((driver) {
        return DataRow(
          cells: [
            DataCell(Text(driver.name)),
            DataCell(Text(driver.phoneNumber)),
          ],
        );
      }).toList(),
    );
  }
}

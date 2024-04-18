import 'package:flutter/material.dart';
import 'package:pixandrix/admin/add%20owners/add_owner.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';

class OwnersPage extends StatefulWidget {
  const OwnersPage({Key? key}) : super(key: key);

  @override
  _OwnersPageState createState() => _OwnersPageState();
}

class _OwnersPageState extends State<OwnersPage> {
  List<OwnerData>? owners;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  Future<void> _loadOwners() async {
    owners = (await FirebaseOperations.getOwners()) as List<OwnerData>?;
    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated user info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owners'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddButton(
              text: 'Add Owner',
              onPressed: () async {
                // Navigate to the AddOwnerPage and await the result
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddOwnerPage()),
                );
                // Refresh the owners list after adding a new owner
                _loadOwners();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildOwnersTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnersTable() {
    if (owners == null) {
      return const Center(
        child: CircularProgressIndicator(), // Show loading indicator while data is being fetched
      );
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Mobile')),
        DataColumn(label: Text('Location')),
      ],
      rows: owners!.map((owner) {
        return DataRow(
          cells: [
            DataCell(Text(owner.name)),
            DataCell(Text(owner.phoneNumber)),
            DataCell(Text(owner.location)),
          ],
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pixandrix/admin/add%20owners/add_owner.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/theme/buttons/add_button.dart';
import 'package:pixandrix/widgets/owner_card.dart';

class OwnersPage extends StatefulWidget {
  const OwnersPage({super.key});

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
    // Fetch owners data and cast it to a List<OwnerData>
    final fetchedOwners = await FirebaseOperations.getOwners();
    owners = fetchedOwners.cast<OwnerData>();

    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated owners data
    }
  }

  Future<void> _removeOwner(int index) async {
    // Remove the driver at the specified index from the list
    if (index >= 0 && index < owners!.length) {
      final ownerToRemove = owners![index];
      await FirebaseOperations.removeOwner(ownerToRemove.name);
      _loadOwners(); // Refresh the drivers list after removing the driver
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
  child: owners == null
      ? const Center(child: CircularProgressIndicator()) // Show loading indicator if owners data is null
      : ListView.builder(
          itemCount: owners!.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                OwnerCard(
                  name: owners![index].name,
                  image: owners![index].ownerImage,
                  mobile: owners![index].phoneNumber,
                  latitude: owners![index].latitude,
                  longitude: owners![index].longitude,
                  press: () {
                    // Handle onTap event here
                  }, onDelete: () { 
                    _removeOwner(index);
                  }, 
                ),
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

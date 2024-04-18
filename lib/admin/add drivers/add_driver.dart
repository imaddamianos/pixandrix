import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/admin/admin_panel.dart';

class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key});

  @override
  _AddOwnerPageState createState() => _AddOwnerPageState();
}

class _AddOwnerPageState extends State<AddDriverPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  // late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    // _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    // _locationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String phoneNumber = _phoneNumberController.text;
      // String location = _locationController.text;

      // Save data to Firestore
      FirebaseFirestore.instance.collection('drivers').add({
        'name': name,
        'phoneNumber': phoneNumber,
        // 'location': location,
      });

      // Clear the form fields
      _nameController.clear();
      _phoneNumberController.clear();
      // _locationController.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPanelPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Driver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              // TextFormField(
              //   controller: _locationController,
              //   decoration: const InputDecoration(labelText: 'Location'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a location';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

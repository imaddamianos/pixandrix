import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/admin/admin_panel.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/helpers/image_id.dart';
import 'package:pixandrix/helpers/profile_pic.dart';

File? _selectedImage;
File? _selectedIDImage;

class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key});

  @override
  _AddOwnerPageState createState() => _AddOwnerPageState();
}

class _AddOwnerPageState extends State<AddDriverPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

   Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    String name = _nameController.text;
    String phoneNumber = _phoneNumberController.text;
    
    try {
      // Upload image and get download URL
      final imageUrl = await FirebaseOperations().uploadImage('Drivers_images', name, _selectedImage!);
      final imageIDUrl = await FirebaseOperations().uploadImage('Drivers_ID', name, _selectedIDImage!);

      // Save data to Firestore
      await FirebaseFirestore.instance.collection('drivers').add({
        'name': name,
        'phoneNumber': phoneNumber,
        'driverImage': imageUrl,
        'driverID' : imageIDUrl,
        'password' : '',
        
      });

      // Clear the form fields
      _nameController.clear();
      _phoneNumberController.clear();
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const AdminPanelPage()),
      );

    } catch (error) {
      print('Error submitting form: $error');
      // Handle error (show a message, log, etc.)
    }
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
              ProfilePic(
              onPickImage: (File pickedImage) {
                _selectedImage = pickedImage;
              },
              imageUrl: '',
            ),
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
              PersonalIdUploader(
              onPickImage: (File pickedImage) {
                _selectedIDImage = pickedImage;
              },
              imageUrl: '',
            ),
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

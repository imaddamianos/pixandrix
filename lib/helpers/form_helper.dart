import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/admin/admin_panel.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/owners/owners_home_page.dart';

Future<void> submitForm({
  required String imageUrl,
  required String name,
  required String password,
  required String phoneNumber,
  required String rate,
  required String location,
  
  required File selectedImage,
  required BuildContext context,
}) async {
  try {
    // Save data to Firestore
    await FirebaseFirestore.instance.collection('owners').add({
      'name': name,
      'phoneNumber': phoneNumber,
      'location': location,
      'ownerImage': imageUrl,
      'password': password,
      'rate' : rate,
      'orderTime': '',
      'orderLocation': '',
    });

    // Clear the form fields
    // You may need to pass controllers to clear them if needed
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    // Clear the form fields
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OwnersHomePage()),
    );
  } catch (error) {
    print('Error submitting form: $error');
    // Handle error (show a message, log, etc.)
    // You can throw the error to handle it in the caller function if needed
    rethrow;
  }
}

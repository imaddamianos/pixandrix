import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/owners/owners_home_page.dart';

OwnerData submitFormStore({
  required String imageUrl,
  required String name,
  required String password,
  required String phoneNumber,
  required String rate,
  required double olatitude,
  required double olongitude,
  required BuildContext context,
  required File selectedImage,
  required bool verified,
  required bool isAvailable,
}) {
  try {
    // Save data to Firestore
    FirebaseFirestore.instance.collection('owners').add({
      'name': name,
      'phoneNumber': phoneNumber,
      'userLocation': {
        'latitude': olatitude,
        'longitude': olongitude,
      },
      'ownerImage': imageUrl,
      'password': password,
      'rate': rate,
      'orderTime': '',
      'orderLocation': '',
      'verified' : verified,
      'isAvailable' : isAvailable
    });

    showAlertWithDestination(
      context,
      'Success',
      'Store created, check verification with admin',
      const FirstPage(),
    );

    // Create and return the OwnerData instance
    return OwnerData(
      name: name,
      phoneNumber: phoneNumber,
      latitude: olatitude,
      longitude: olongitude,
      ownerImage: imageUrl,
      password: password,
      rate: rate,
      verified: verified,
      isAvailable: isAvailable,
    );
  } catch (error) {
    print('Error submitting form: $error');
    // Handle error (show a message, log, etc.)
    // You can throw the error to handle it in the caller function if needed
    rethrow;
  }
}


  Future<DriverData> submitFormDriver({
    required String imageUrl,
    required String imageIDUrl,
    required String name,
    required String password,
    required String phoneNumber,
    required File selectedImage,
    required bool verified,
     required bool isAvailable,
    required BuildContext context,
  }) async {
    try {
      // Save data to Firestore
      await FirebaseFirestore.instance.collection('drivers').add({
        'name': name,
        'phoneNumber': phoneNumber,
        'driverImage': imageUrl,
        'password': password,
        'driverID' : imageIDUrl,
        'verified' : verified,
        'isAvailable' : isAvailable
      });

      showAlertWithDestination(
      context,
      'Success',
      'Driver created, check verification with admin',
      const FirstPage(),
    );

      return DriverData(
      name: name,
      phoneNumber: phoneNumber,
      verified: verified,
      driverImage: imageUrl,
      driverID: '',
      isAvailable: isAvailable,
    );
    } catch (error) {
      print('Error submitting form: $error');
      // Handle error (show a message, log, etc.)
      // You can throw the error to handle it in the caller function if needed
      rethrow;
    }
  }

  Future<void> submitFormOrder({
  required DateTime orderTime,
  required String orderLocation,
  required OrderStatus status,
  required bool isTaken,
  required String driverInfo,
  required String storeInfo,
  required BuildContext context,
}) async {
  try {
    // Get the next order number
    int orderNumber = await getNextOrderNumber();

    // Save order data to Firestore
    await FirebaseFirestore.instance.collection('orders').add({
      'orderID': 'ORD$orderNumber', // Use order number as the ID
      'orderTime': orderTime,
      'orderLocation': orderLocation,
      'status': status.toString(),
      'isTaken': isTaken,
      'driverInfo': driverInfo,
      'storeInfo': storeInfo,
      // You can add more fields here if needed
    });

    showAlertWithDestination(context, 'Success', 'Order created with ID: ORD$orderNumber', const OwnersHomePage());
  } catch (error) {
    print('Error submitting form: $error');
    // Handle error (show a message, log, etc.)
    // You can throw the error to handle it in the caller function if needed
    rethrow;
  }
}

Future<int> getNextOrderNumber() async {
  try {
    // Get the current order number
    DocumentSnapshot orderNumberSnapshot = await FirebaseFirestore.instance.collection('ordersNumber').doc('orderNumber').get();
    int currentOrderNumber = orderNumberSnapshot.exists ? orderNumberSnapshot['value'] : 0;

    // Increment the order number by 1
    int nextOrderNumber = currentOrderNumber + 1;

    // Update the order number in Firestore
    await FirebaseFirestore.instance.collection('ordersNumber').doc('orderNumber').set({'value': nextOrderNumber});

    return nextOrderNumber;
  } catch (error) {
    print('Error getting next order number: $error');
    // You can handle the error here as needed
    throw error;
  }
}


  

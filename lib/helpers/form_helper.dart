import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';

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
    });

    // Create and return the OwnerData instance
    return OwnerData(
      name: name,
      phoneNumber: phoneNumber,
      latitude: olatitude,
      longitude: olongitude,
      ownerImage: imageUrl,
      password: password,
      rate: rate,
    );
  } catch (error) {
    print('Error submitting form: $error');
    // Handle error (show a message, log, etc.)
    // You can throw the error to handle it in the caller function if needed
    rethrow;
  }
}


  Future<void> submitFormDriver({
    required String imageUrl,
    required String imageIDUrl,
    required String name,
    required String password,
    required String phoneNumber,
    required File selectedImage,
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
      });
      showAlertDialog(
      context,
      'Success',
      'Account created, you can log in',
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
    required DriverData driverInfo,
    required String storeInfo,
    required BuildContext context,
  }) async {
    try {
      // Save data to Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'orderTime': orderTime,
        'orderLocation': orderLocation,
        'status': status.toString(),
        'isTaken': isTaken,
        'driverInfo' : driverInfo.name,
        'OwnerData' : storeInfo,
      });
      showAlertDialog(
      context,
      'Success',
      'Order created',
    );
    } catch (error) {
      print('Error submitting form: $error');
      // Handle error (show a message, log, etc.)
      // You can throw the error to handle it in the caller function if needed
      rethrow;
    }
  }
  

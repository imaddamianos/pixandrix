import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/owner_model.dart';

class FirebaseOperations {
  // Create an instance of AuthService

  Future<String> uploadImage(String user, File selectedImage) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('driver_image').child('$user.jpg');
      await storageRef.putFile(selectedImage);

      // Get the download URL of the uploaded image
      var imageUrl = await storageRef.getDownloadURL();

      return imageUrl;
    } catch (error) {
      print('Error uploading image: $error');
      return 'no image'; // Return an empty string in case of an error
    }
  }

   static Future<List<OwnerData>> getOwners() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('owners').get();

      List<OwnerData> owners =
          await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data();

        return OwnerData(
          location: data['location'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          ownerImage: data['ownerImage'],
        );
      }).toList());

      return owners;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
    }
  }

  static Future<List<DriverData>> getDrivers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('drivers').get();

      List<DriverData> drivers =
          await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data();

        return DriverData(
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          driverImage: data['driverImage'],
        );
      }).toList());

      return drivers;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
    }
  }

}

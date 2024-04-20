import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/owner_model.dart';

class FirebaseOperations {

  static Future<bool> checkRestaurantNameExists(String restaurantName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('owners')
          .where('name', isEqualTo: restaurantName)
          .limit(1) // Limit to 1 document since we only need to check if it exists
          .get();

      // If there's at least one document with the given restaurant name, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking restaurant name: $e');
      return false;
    }
  }

  static Future<void> removeOwner(String name) async {
    try {
      // Query the Firestore collection to find the document with the specified name
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('owners')
          .where('name', isEqualTo: name)
          .get();

      // Check if any documents with the specified name were found
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the first document found (assuming there's only one document with the same name)
        await querySnapshot.docs.first.reference.delete();
      } else {
        print('No owner found with the name: $name');
      }
    } catch (e) {
      print('Error removing owner: $e');
      throw e;
    }
  }

 static Future<void> removeDriver(String name) async {
    try {
      // Query the Firestore collection to find the document with the specified name
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('name', isEqualTo: name)
          .get();

      // Check if any documents with the specified name were found
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the first document found (assuming there's only one document with the same name)
        await querySnapshot.docs.first.reference.delete();
      } else {
        print('No driver found with the name: $name');
      }
    } catch (e) {
      print('Error removing driver: $e');
      throw e;
    }
  }

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

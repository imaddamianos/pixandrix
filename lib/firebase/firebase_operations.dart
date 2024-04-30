import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';

class FirebaseOperations {
  static Future<bool> checkRestaurantNameExists(String restaurantName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('owners')
          .where('name', isEqualTo: restaurantName)
          .limit(
              1) // Limit to 1 document since we only need to check if it exists
          .get();

      // If there's at least one document with the given restaurant name, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking restaurant name: $e');
      return false;
    }
  }

  static Future<bool> checkDriverNameExists(String driverName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('drivers')
          .where('name', isEqualTo: driverName)
          .limit(
              1) // Limit to 1 document since we only need to check if it exists
          .get();

      // If there's at least one document with the given restaurant name, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking driver name: $e');
      return false;
    }
  }

  static Future<bool> checkRestaurantPassword() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('owners')
          .where('password', isEqualTo: '')
          .limit(
              1) // Limit to 1 document since we only need to check if it exists
          .get();

      // If there's at least one document with the given restaurant name, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking restaurant password: $e');
      return false;
    }
  }

  static Future<void> removeOwner(String name) async {
    try {
      // Query the Firestore collection to find the document with the specified name
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
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

  static Future<void> removeOrder(String name) async {
    try {
      // Query the Firestore collection to find the document with the specified name
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .where('OwnerData', isEqualTo: name)
              .get();

      // Check if any documents with the specified name were found
      if (querySnapshot.docs.isNotEmpty) {
        // Delete the first document found (assuming there's only one document with the same name)
        await querySnapshot.docs.first.reference.delete();
      } else {
        print('No order found with the name: $name');
      }
    } catch (e) {
      print('Error removing order: $e');
      throw e;
    }
  }

  static Future<void> removeDriver(String name) async {
    try {
      // Query the Firestore collection to find the document with the specified name
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
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

  Future<String> uploadImage(
      String path, String user, File selectedImage) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(path).child('$user.jpg');
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
          latitude: data['userLocation']['latitude'],
          longitude: data['userLocation']['longitude'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          ownerImage: data['ownerImage'],
          rate: data['rate'],
          password: data['password'],
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
          driverID: data['driverID'],
        );
      }).toList());

      return drivers;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
    }
  }

  static Future<List<OrderData>> getOrders() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      List<OrderData> orders =
          await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data();

        return OrderData(
          orderLocation: data['orderLocation'],
          status: data['status'],
          // isTaken: data['isTaken'],
          driverInfo: data['driverInfo'],
          storeInfo: data['OwnerData'],
          orderTime: data['orderTime'],
        );
      }).toList());

      return orders;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
    }
  }

  static Future<OwnerData?> checkOwnerCredentials(
      String type, String name, String password) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(type)
              .where('name', isEqualTo: name)
              .where('password', isEqualTo: password)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Extract owner information from the first document
        Map<String, dynamic> data = querySnapshot.docs.first.data();

        return OwnerData(
            name: data['name'],
            phoneNumber: data['phoneNumber'],
            ownerImage: data['ownerImage'],
            latitude: data['userLocation']['latitude'],
            longitude: data['userLocation']['longitude'],
            rate: data['rate'],
            password: data['password']);
      } else {
        // If no documents are found, return null
        return null;
      }
    } catch (error) {
      // If an error occurs, print the error and return null
      print('Error checking login credentials: $error');
      return null;
    }
  }

  static Future<DriverData?> checkDriverCredentials(
      String type, String name, String password) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(type)
              .where('name', isEqualTo: name)
              .where('password', isEqualTo: password)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Extract owner information from the first document
        Map<String, dynamic> data = querySnapshot.docs.first.data();

        return DriverData(
          driverID: data['driverID'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          driverImage: data['driverImage'],
        );
      } else {
        // If no documents are found, return null
        return null;
      }
    } catch (error) {
      // If an error occurs, print the error and return null
      print('Error checking login credentials: $error');
      return null;
    }
  }
static Future<void> changeOrderStatus(String newStatus, String ownerId) async {
  
    try {
      // Reference to the orders collection
      CollectionReference ordersRef =
          FirebaseFirestore.instance.collection('orders');

      // Check if the order belongs to the owner
      QuerySnapshot orderSnapshot =
          await ordersRef.where('OwnerData', isEqualTo: ownerId).limit(1).get();

      // If order belongs to the owner, update the status
      if (orderSnapshot.docs.isNotEmpty) {
        String docId = orderSnapshot.docs.first.id;
        await ordersRef.doc(docId).update({'status': newStatus});
      } else {
        throw Exception('Order not found or does not belong to owner');
      }
    } catch (e) {
      print('Error changing order status: $e');
      // Handle error
    }
  }
}

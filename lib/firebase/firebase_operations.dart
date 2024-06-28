import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/helpRequest_model.dart';
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
          verified: data['verified'],
          isAvailable: data['isAvailable'],
        );
      }).toList());

      return owners;
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
            password: data['password'],
            verified: data['verified'],
            isAvailable: data['isAvailable'],
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

  static Future<bool> checkDriverVerification(String driverName) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('drivers')
        .where('name', isEqualTo: driverName)
        .where('verified', isEqualTo: true)
        .limit(1)
        .get();

    // If there's at least one document with the given driver name and verified field is true, return true
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    print('Error checking driver verification: $e');
    return false;
  }
}

static Future<bool> checkOwnerVerification(String ownerName) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('owners')
        .where('name', isEqualTo: ownerName)
        .where('verified', isEqualTo: true)
        .limit(1)
        .get();

    // If there's at least one document with the given driver name and verified field is true, return true
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    print('Error checking owner verification: $e');
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

  static Future<bool> checkAdminPass(String enteredPassword) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('admin')
          .where('password', isEqualTo: enteredPassword)
          .limit(
              1) // Limit to 1 document since we only need to check if it exists
          .get();

      // If there's at least one document with the given restaurant name, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking Admin password: $e');
      return false;
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
              .where('verified', isEqualTo: true)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Extract owner information from the first document
        Map<String, dynamic> data = querySnapshot.docs.first.data();

        return DriverData(
          driverID: data['driverID'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          driverImage: data['driverImage'],
          verified: data['verified'],
          isAvailable: data['isAvailable'],
          password: data['password'],
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
          verified: data['verified'],
          isAvailable: data['isAvailable'],
          password: data['password'],
        );
      }).toList());

      return drivers;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
    }
  }

  static Future<DriverData?> getDriverByName(String driverName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('drivers').get();

      var driverDoc = querySnapshot.docs.firstWhere(
        (doc) => doc.data()['name'] == driverName,
      );

      Map<String, dynamic> data = driverDoc.data();

      return DriverData(
        name: data['name'],
        phoneNumber: data['phoneNumber'],
        driverImage: data['driverImage'],
        driverID: data['driverID'],
        verified: data['verified'],
        isAvailable: data['isAvailable'],
        password: data['password'],
      );
        } catch (e) {
      print('Error fetching driver: $e');
      throw e;
    }
  }

  static Future<OwnerData> getOwnerByName(String ownerrName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('owners').get();

      var downerDoc = querySnapshot.docs.firstWhere(
        (doc) => doc.data()['name'] == ownerrName,
      );

      Map<String, dynamic> data = downerDoc.data();

      return OwnerData(
          latitude: data['userLocation']['latitude'],
          longitude: data['userLocation']['longitude'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          ownerImage: data['ownerImage'],
          rate: data['rate'],
          password: data['password'],
          verified: data['verified'],
          isAvailable: data['isAvailable'],
        );
        } catch (e) {
      print('Error fetching owner: $e');
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

  static Future<List<OrderData>> getOrders() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      List<OrderData> orders =
          await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data();

        return OrderData(
          orderID : data['orderID'],
          orderLocation: data['orderLocation'],
          status: data['status'],
          isTaken: data['isTaken'],
          driverInfo: data['driverInfo'],
          storeInfo: data['storeInfo'],
          orderTime: data['orderTime'],
          lastOrderTimeUpdate: data['lastOrderTimeUpdate'],
          orderTimeTaken: data['orderTimeTaken'],
        );
      }).toList());

      return orders;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
    }
  }

  static Future<void> changeDriverVerification(String driverName, bool isVerified) async {
    try {
      CollectionReference ordersRef =
          FirebaseFirestore.instance.collection('drivers');
      QuerySnapshot orderSnapshot =
          await ordersRef.where('name', isEqualTo: driverName).limit(1).get();
      if (orderSnapshot.docs.isNotEmpty) {
        String docId = orderSnapshot.docs.first.id;
        await ordersRef.doc(docId).update({'verified': isVerified});
      } else {
        throw Exception('Driver not found or does not belong');
      }
    } catch (e) {
      print('Error toggling driver verification status: $e');
      // Handle error
    }
  }

  static Future<void> changeOwnerVerification(String ownerName, bool isVerified) async {
    try {
      CollectionReference ordersRef =
          FirebaseFirestore.instance.collection('owners');
      QuerySnapshot orderSnapshot =
          await ordersRef.where('name', isEqualTo: ownerName).limit(1).get();
      if (orderSnapshot.docs.isNotEmpty) {
        String docId = orderSnapshot.docs.first.id;
        await ordersRef.doc(docId).update({'verified': isVerified});
      } else {
        throw Exception('Owner not found or does not belong');
      }
    } catch (e) {
      print('Error toggling Owner verification status: $e');
      // Handle error
    }
  }

   static Future<void> changeDriverAvailable(String driverName, bool isAvailable) async {
    try {
      CollectionReference ordersRef =
          FirebaseFirestore.instance.collection('drivers');
      QuerySnapshot orderSnapshot =
          await ordersRef.where('name', isEqualTo: driverName).limit(1).get();
      if (orderSnapshot.docs.isNotEmpty) {
        String docId = orderSnapshot.docs.first.id;
        await ordersRef.doc(docId).update({'isAvailable': isAvailable});
      } else {
        throw Exception('Driver not found or does not belong');
      }
    } catch (e) {
      print('Error toggling Driver Available status: $e');
      // Handle error
    }
  }

  static Future<void> changeOrderStatus(String newStatus, String orderId, String driverName) async {
  try {
    // Reference to the orders collection
    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('orders');

    // Check if the order exists
    DatabaseEvent orderSnapshot = await ordersRef.orderByChild('orderID').equalTo(orderId).once();

    // If order exists, update the status
    if (orderSnapshot.snapshot.value != null) {
      Map<dynamic, dynamic> orders = orderSnapshot.snapshot.value as Map<dynamic, dynamic>;
      String key = orders.keys.first;

      DateTime now = DateTime.now().toLocal();
      Map<String, dynamic> updates = {
        'status': newStatus,
        'driverInfo': driverName,
        'lastOrderTimeUpdate': now.toIso8601String(),
      };

      await ordersRef.child(key).update(updates);
    } else {
      throw Exception('Order not found');
    }
  } catch (e) {
    print('Error changing order status: $e');
    // Handle error
  }
}

  static Future<void> changeOrderTaken(String orderId) async {
  try {
    // Reference to the orders node in the Realtime Database
    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('orders');

    // Check if the order exists
    DatabaseEvent orderSnapshot = await ordersRef.orderByChild('orderID').equalTo(orderId).once();

    // If order exists, update the 'isTaken' field
    if (orderSnapshot.snapshot.value != null) {
      Map<dynamic, dynamic> orders = orderSnapshot.snapshot.value as Map<dynamic, dynamic>;
      String key = orders.keys.first;

      await ordersRef.child(key).update({'isTaken': false});
    } else {
      throw Exception('Order not found');
    }
  } catch (e) {
    print('Error changing order status: $e');
    // Handle error
  }
}

  static Future<void> addTokentoUsers(String ownerName, String driverName) async {
    final fCMToken = await FirebaseMessaging.instance.getToken();
  try {
    // Reference to the orders collection
    if(ownerName != ''){
      CollectionReference ordersRef = FirebaseFirestore.instance.collection('owners');
    QuerySnapshot orderSnapshot = await ordersRef.where('name', isEqualTo: ownerName).limit(1).get();

    if (orderSnapshot.docs.isNotEmpty) {
      String docId = orderSnapshot.docs.first.id;
      await ordersRef.doc(docId).update({
        'token': fCMToken
      });
    } else {
      throw Exception('Order not found or does not belong to owner');
    }
    }else if(driverName != ''){
      CollectionReference ordersRef = FirebaseFirestore.instance.collection('drivers');
    QuerySnapshot orderSnapshot = await ordersRef.where('name', isEqualTo: driverName).limit(1).get();
    if (orderSnapshot.docs.isNotEmpty) {
      String docId = orderSnapshot.docs.first.id;
      await ordersRef.doc(docId).update({
        'token': fCMToken
      });
    } else {
      throw Exception('Order not found or does not belong to owner');
    }
    }else{
        CollectionReference ordersRef = FirebaseFirestore.instance.collection('admin');
    QuerySnapshot orderSnapshot = await ordersRef.where('name').limit(1).get();
    if (orderSnapshot.docs.isNotEmpty) {
      String docId = orderSnapshot.docs.first.id;
      await ordersRef.doc(docId).update({
        'token': fCMToken
      });
    } else {
      throw Exception('Order not found or does not belong to owner');
    }
    }
    

   
  } catch (e) {
    print('Error changing order status: $e');
    // Handle error
  }
}

  static Future<void> removeOrder(String orderNumber) async {
  try {
    // Reference to the orders node in the Realtime Database
    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('orders');

    // Query the Realtime Database to find the order with the specified order number
    DatabaseEvent orderSnapshot = await ordersRef.orderByChild('orderID').equalTo(orderNumber).once();

    // Check if any orders with the specified order number were found
    if (orderSnapshot.snapshot.value != null) {
      Map<dynamic, dynamic> orders = orderSnapshot.snapshot.value as Map<dynamic, dynamic>;
      String key = orders.keys.first;

      // Delete the order
      await ordersRef.child(key).remove();
    } else {
      print('No order found with the order number: $orderNumber');
    }
  } catch (e) {
    print('Error removing order: $e');
    throw e;
  }
}

  static Future<List<HelpRequestData>> getHelpRequest() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('helpRequests').get();

      List<HelpRequestData> helpRequest =
          await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data();

        return HelpRequestData(
          description: data['description'],
          longitude: data['userLocation']['longitude'],
          latitude: data['userLocation']['latitude'],
          driverInfo: data['driverInfo'],
          driverNumber: data['driverNumber'],
          isHelped: data['isHelped'],
          timestamp: data['timestamp'],
        );
      }).toList());

      return helpRequest;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
    }
  }
  static Future<void> changeHelpStatus(bool isHelped, String description) async {
    try {
      // Reference to the orders collection
      CollectionReference ordersRef =
          FirebaseFirestore.instance.collection('helpRequests');

      // Check if the order belongs to the owner
      QuerySnapshot orderSnapshot =
          await ordersRef.where('description', isEqualTo: description).limit(1).get();

      // If order belongs to the owner, update the status
      if (orderSnapshot.docs.isNotEmpty) {
        String docId = orderSnapshot.docs.first.id;
        await ordersRef.doc(docId).update({'isHelped': isHelped});
      } else {
        throw Exception('help not found or does not belong to driver');
      }
    } catch (e) {
      print('Error changing driver help: $e');
      // Handle error
    }
  }
}

  
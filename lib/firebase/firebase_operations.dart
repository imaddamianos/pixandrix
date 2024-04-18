import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

// Future<Owner?> getOwners() async {
//     try {
//       final ref = FirebaseDatabase.instance.ref();
//       final snapshot = await ref
//           .child('owners')
//           .get();

//       if (snapshot.exists) {
//         final userData = snapshot.value as Map<dynamic, dynamic>?;

//         if (userData != null) {
//           Owner userInfo = Owner(
//             name: userData['name'],
//             location: userData['location'],
//             phoneNumber: userData['phoneNumber'],
//             ownerImage: userData['ownerImage'],
//           );

//           return userInfo;
//         }
//       } else {
//         print('No data available.');
//         return null;
//       }
//     } catch (error) {
//       print('Error getting user info: $error');
//       return null;
//     }
//     return null;
//   }

   static Future<List<OwnerData>> getOwners() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('owners').get();

      List<OwnerData> stores =
          await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data();

        return OwnerData(
          location: data['location'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          ownerImage: data['ownerImage'],
        );
      }).toList());

      return stores;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
    }
  }

}

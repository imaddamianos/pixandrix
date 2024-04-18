import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseOperations {
  final _databaseReference = FirebaseDatabase.instance.reference();
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

  Future<void> sendDriverData({
    required String name,
    required String phoneNumber,
    required File? driverImage,
  }) async {
    try {

      final imageUrl = await uploadImage(name, driverImage!);

      final driverData = {
        'name': name,
        'phoneNumber': phoneNumber,
        'image': imageUrl,
      };

      await _databaseReference
          .child('drivers')
          .child(name)
          .set(driverData);
    } catch (error) {
      print('Error sending user data: $error');
      // Handle error (show a message, log, etc.)
    }
  }
}

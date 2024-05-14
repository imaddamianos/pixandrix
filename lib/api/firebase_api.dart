
import 'package:firebase_messaging/firebase_messaging.dart';

class FireBaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async{
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');

  }
}
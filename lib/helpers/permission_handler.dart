import 'package:permission_handler/permission_handler.dart';

// Request location permission
Future<void> getLocationPermission() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    // Permission granted, proceed with location-related tasks
  } else {
    // Permission denied, handle accordingly
  }
}


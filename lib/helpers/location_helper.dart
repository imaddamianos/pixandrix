import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pixandrix/helpers/secure_storage.dart';

Future<LatLng> getUserLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    print("Error getting user location: $e");
    rethrow; // Rethrow the error to handle it in the caller function
  }
}


Future<void> navigateAndRefresh(StatefulWidget page, BuildContext context) async {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (BuildContext context) => page),
    (route) => false,
  );
}


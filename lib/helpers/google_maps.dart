import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleMapWidget extends StatefulWidget {
  final GeoPoint initialLocation;

  const GoogleMapWidget({Key? key, required this.initialLocation})
      : super(key: key);

  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late LatLng userLocation;
  late GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    userLocation = LatLng(
        widget.initialLocation.latitude, widget.initialLocation.longitude);
  }

  Future<void> _getUserLocation() async {
    LocationData? currentLocation;
    var location = Location();
    try {
      currentLocation = await location.getLocation();
      setState(() {
        userLocation = LatLng(
          currentLocation?.latitude ?? widget.initialLocation.latitude,
          currentLocation?.longitude ?? widget.initialLocation.longitude,
        );
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(userLocation));
    } catch (e) {
      print("Error getting location: $e");
      // Handle error or show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _getUserLocation,
      //   child: const Icon(Icons.location_searching),
      // ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: userLocation,
          zoom: 15,
        ),
        markers: <Marker>{
          Marker(
            markerId: const MarkerId('store'),
            position: userLocation,
            infoWindow: const InfoWindow(title: 'Map'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}

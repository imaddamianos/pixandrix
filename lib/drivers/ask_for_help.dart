import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixandrix/helpers/location_helper.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class AskForHelpPage extends StatefulWidget {
  final DriverData? driverInfo;

  const AskForHelpPage({super.key, required this.driverInfo});

  @override
  _AskForHelpPageState createState() => _AskForHelpPageState();
}

class _AskForHelpPageState extends State<AskForHelpPage> {
  final TextEditingController _descriptionController = TextEditingController();
  LatLng? userLocation = const LatLng(33.8657637, 35.5203407);
  late GoogleMapController _mapController;

  void _sendHelpRequest() async {
    String description = _descriptionController.text;

    if (userLocation != null && description.isNotEmpty) {
      await FirebaseFirestore.instance.collection('helpRequests').add({
        'driverInfo': widget.driverInfo?.name,
        'driverNumber': widget.driverInfo?.phoneNumber,
        'userLocation': {
          'latitude': userLocation?.latitude,
          'longitude': userLocation?.longitude,
        },
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'isHelped': false,
      });

      // Clear the text fields
      _descriptionController.clear();

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Help request sent successfully!')),
      );

      // Optionally navigate back
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location and fill in the description'),
        ),
      );
    }
  }

  Future<void> _updateUserLocation() async {
    try {
      LatLng location = await getUserLocation();
      setState(() {
        userLocation = location;
      });
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(userLocation!.latitude, userLocation!.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      print("Error updating user location: $e");
    }
  }

  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      userLocation = tappedPoint;
    });
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: tappedPoint, zoom: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask for Help'),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(userLocation!.latitude, userLocation!.longitude),
                    zoom: 15.0,
                  ),
                  markers: {
                    if (userLocation != null)
                      Marker(
                        markerId: const MarkerId("userLocation"),
                        position: userLocation!,
                        infoWindow: const InfoWindow(title: "Current Location"),
                      ),
                  },
                  onTap: _onMapTapped,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _updateUserLocation,
                child: const Text("Get My Location"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Help Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendHelpRequest,
                child: const Text('Send Help Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

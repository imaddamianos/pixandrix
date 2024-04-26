import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapsView extends StatelessWidget {
  final double latitude;
  final double longitude;

  const GoogleMapsView({
    required this.latitude,
    required this.longitude,
  });

  Future<void> _launchDirections(double destinationLatitude, double destinationLongitude) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 14,
              ),
              myLocationEnabled: true, // Show current user's location in blue
              markers: {
                Marker(
                  markerId: const MarkerId('owner_location'),
                  position: LatLng(latitude, longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Red pin for received coordinate
                  infoWindow: const InfoWindow(
                    title: 'Owner Location',
                  ),
                ),
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _launchDirections(latitude, longitude);
            },
            child: const Text('Get Directions'),
          ),
        ],
      ),
    );
  }
}

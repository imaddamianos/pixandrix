import 'package:flutter/material.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'package:pixandrix/widgets/google_maps_view.dart';

class OwnerCardWindow extends StatelessWidget {
  final String ownerName;
  final String ownerImage;
  final String ownerMobile;
  final double latitude;
  final double longitude;
  final String rate;

  const OwnerCardWindow({super.key, 
    required this.ownerName,
    required this.ownerImage,
    required this.ownerMobile,
    required this.latitude,
    required this.longitude,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(ownerImage),
              ),
              const SizedBox(height: 10),
              Text(
                ownerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              const SizedBox(height: 10,),
              Text(
                'Mobile: $ownerMobile',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              const SizedBox(height: 10,),
              Text(
                'Rate: $rate L.L',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              const SizedBox(height: 10,),
              CustomButton(text: 'Open Map', onPressed: () {
                  // Open Google Maps
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoogleMapsView(
                        latitude: latitude,
                        longitude: longitude,
                      ),
                    ),
                  );
                },
                ),
            ],
          ),
        ),
      ),
    );
  }
}


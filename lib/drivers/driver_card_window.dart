import 'package:flutter/material.dart';

class DriverCardWindow extends StatelessWidget {
  final String driverName;
  final String driverImage;
  final String driverMobile;
  final String driverID;

  const DriverCardWindow({
    super.key,
    required this.driverName,
    required this.driverImage,
    required this.driverMobile,
    required this.driverID,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(driverImage),
              ),
              const SizedBox(height: 10),
              Text(
                driverName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Mobile: $driverMobile ',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Driver ID',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(driverID),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

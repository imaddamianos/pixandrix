import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'package:pixandrix/widgets/google_maps_view.dart';

class OrderCardDriversWindow extends StatefulWidget {
  final String ownerName;
  final String orderID;
  final String orderAddress;

  const OrderCardDriversWindow({
    super.key,
    required this.ownerName,
    required this.orderID,
    required this.orderAddress,
  });

  @override
  _OrderCardDriversWindowState createState() => _OrderCardDriversWindowState();
}

class _OrderCardDriversWindowState extends State<OrderCardDriversWindow> {
  OwnerData? ownerData;

  @override
  void initState() {
    super.initState();
    // Call the getDriverByName function and retrieve driver data
    FirebaseOperations.getOwnerByName(widget.ownerName).then((data) {
      setState(() {
        ownerData = data; // Update the driverData variable with retrieved data
      });
    }).catchError((error) {
      print('Error retrieving owner data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Order Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Text(
                '# ${widget.orderID}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              Text(
                'Delivery to: ${widget.orderAddress}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Store Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Text(
                 'Name: ${widget.ownerName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              Center(
                child: ownerData != null // Check if driver data is available
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Number: ${ownerData!.phoneNumber}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 152, 152, 152),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Rate: ${ownerData!.rate}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 152, 152, 152),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                NetworkImage(ownerData!.ownerImage),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomButton(
                            text: 'Open Map',
                            onPressed: () {
                              // Open Google Maps
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GoogleMapsView(
                                    latitude: ownerData!.latitude,
                                    longitude: ownerData!.longitude,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(), // Display a loading indicator if data is being fetched
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/driver_model.dart';

class OrderCardOwnersWindow extends StatefulWidget {
  final String driverName;
  final String orderID;
  final String orderLocation;

  const OrderCardOwnersWindow({
    super.key,
    required this.driverName,
    required this.orderID,
    required this.orderLocation,
  });

  @override
  _OrderCardOwnersWindowState createState() => _OrderCardOwnersWindowState();
}

class _OrderCardOwnersWindowState extends State<OrderCardOwnersWindow> {
  DriverData? driverData;

  @override
  void initState() {
    super.initState();
    // Call the getDriverByName function and retrieve driver data
    FirebaseOperations.getDriverByName(widget.driverName).then((data) {
      setState(() {
        driverData = data; // Update the driverData variable with retrieved data
      });
    }).catchError((error) {
      print('Error retrieving driver data: $error');
    });
  }

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
              ),Text(
                'Deliver to: ${widget.orderLocation}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Driver Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Text(
                'Name: ${widget.driverName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 152, 152),
                ),
              ),
              Center(
                child: driverData != null // Check if driver data is available
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Number: ${driverData!.phoneNumber}',
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
                                NetworkImage(driverData!.driverImage),
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

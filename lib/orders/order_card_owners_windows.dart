import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/helpers/whatsapp_redirect.dart';
import 'package:pixandrix/models/driver_model.dart';

class OrderCardOwnersWindow extends StatefulWidget {
  final String driverName;
  final String orderID;
  final String orderLocation;
  final String orderTimePlaced;

  const OrderCardOwnersWindow({
    Key? key,
    required this.driverName,
    required this.orderID,
    required this.orderLocation,
    required this.orderTimePlaced,
  }) : super(key: key);

  @override
  _OrderCardOwnersWindowState createState() => _OrderCardOwnersWindowState();
}

class _OrderCardOwnersWindowState extends State<OrderCardOwnersWindow> {
  DriverData? driverData;

  @override
  void initState() {
    super.initState();
    if (widget.driverName.isNotEmpty) {
      FirebaseOperations.getDriverByName(widget.driverName).then((data) {
        setState(() {
          driverData = data;
        });
      }).catchError((error) {
        print('Error retrieving driver data: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        height: 400,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
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
                  'Deliver to: ${widget.orderLocation}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 152, 152, 152),
                  ),
                ),
                Text(
                  'Placed at: ${widget.orderTimePlaced}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 152, 152, 152),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 5),
                if (widget.driverName.isEmpty)
                  const Text(
                    'No Driver',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 152, 152, 152),
                    ),
                  ),
                if (widget.driverName.isNotEmpty)
                  const Text(
                    'Driver Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                if (widget.driverName.isNotEmpty)
                  Text(
                    'Name: ${widget.driverName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 152, 152, 152),
                    ),
                  ),
                Center(
                  child: driverData != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 5),
                            if (widget.driverName.isNotEmpty)
                              InkWell(
                            onTap: () {
                              redirectToWhatsApp(driverData!.phoneNumber);
                            },
                            child: Text(
                              driverData!.phoneNumber,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 0, 162, 255),
                                decoration: TextDecoration
                                    .underline, // Optional: to underline the text
                              ),
                            ),
                          ),
                            const SizedBox(height: 20),
                            if (widget.driverName.isNotEmpty)
                              CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    NetworkImage(driverData!.driverImage),
                              ),
                          ],
                        )
                      : const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

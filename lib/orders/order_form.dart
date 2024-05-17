import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pixandrix/helpers/form_helper.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'package:pixandrix/theme/custom_theme.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({super.key, required this.ownerInfo});

  final OwnerData? ownerInfo;

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
    late OwnerData? ownerInfo;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 0, minute: 15);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    ownerInfo = widget.ownerInfo;
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Enter Location',
                  labelStyle: TextStyle(
                    color: textColor,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the order location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: const Text(
                  'Time',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          _selectedTime = _subtractTime(
                              _selectedTime, const Duration(minutes: 5));
                        });
                      },
                    ),
                    Text(
                      '${_selectedTime.hour}:${_selectedTime.minute}',
                      style: const TextStyle(
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _selectedTime = _addTime(
                              _selectedTime, const Duration(minutes: 5));
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              CustomButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Combine current date with selected time to create order time
                    DateTime orderTime = DateTime.now().add(
                      Duration(
                          hours: _selectedTime.hour,
                          minutes: _selectedTime.minute),
                    );
                    submitFormOrder(
                      orderTime: orderTime,
                      orderLocation: _locationController.text,
                      status: OrderStatus.pending,
                      isTaken: false,
                      driverInfo: '',
                      storeInfo: widget.ownerInfo!.name,
                      context: context,
                    );

                    // Navigator.pop(context);
                  }
                },
                text: 'Submit Order',
              ),
            ],
          ),
        ),
      ),
    );
  }

  TimeOfDay _subtractTime(TimeOfDay time, Duration duration) {
    int minutes = time.hour * 60 + time.minute;
    int subtractedMinutes = (minutes - duration.inMinutes).clamp(15, 60);
    return TimeOfDay(
        hour: subtractedMinutes ~/ 60, minute: subtractedMinutes % 60);
  }

  TimeOfDay _addTime(TimeOfDay time, Duration duration) {
    int minutes = time.hour * 60 + time.minute;
    int addedMinutes = (minutes + duration.inMinutes).clamp(15, 60);
    return TimeOfDay(hour: addedMinutes ~/ 60, minute: addedMinutes % 60);
  }
}

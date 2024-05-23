import 'package:flutter/material.dart';
import 'package:pixandrix/helpers/form_helper.dart';
import 'package:pixandrix/helpers/loader.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/owners/owners_home_page.dart';
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
  bool _isSubmitting = false;
  final GlobalLoader _globalLoader = GlobalLoader();

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
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isSubmitting = true;
                          });

                          // Combine current date with selected time to create order time
                          DateTime orderTime = DateTime.now().add(
                            Duration(
                                hours: _selectedTime.hour,
                                minutes: _selectedTime.minute),
                          );

                          try {
                            int orderNumber = await getNextOrderNumber();
                            await submitFormOrder(
                              orderTime: orderTime,
                              orderLocation: _locationController.text,
                              status: OrderStatus.pending,
                              isTaken: false,
                              driverInfo: '',
                              storeInfo: widget.ownerInfo!.name,
                              context: context,
                              orderNumber: orderNumber,
                            );

                            // Show success dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(

                                title: const Text('Success'),
                                content:
                                    const Text('Order created Successfully', style: TextStyle(color: Colors.black),),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const OwnersHomePage()),
                                      );
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            // Show error dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Failed to submit order. Please try again.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } finally {
                            setState(() {
                              _isSubmitting = false;
                            });
                          }
                        }
                      },
                text: 'Submit Order',
              ),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator()),
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

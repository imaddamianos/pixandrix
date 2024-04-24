import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pixandrix/admin/admin_panel.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/helpers/location_helper.dart';
import 'package:pixandrix/helpers/profile_pic.dart';
import 'package:pixandrix/models/owner_model.dart';

class StoreLoginPage extends StatefulWidget {
  const StoreLoginPage({super.key, this.ownerInfo});
  final OwnerData? ownerInfo;

  @override
  _StoreLoginPageState createState() => _StoreLoginPageState();
}

class _StoreLoginPageState extends State<StoreLoginPage> {
  late File? _selectedImage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final String _errorMessage = '';
  String _passMessage = '';
  bool _restaurantNameAvailable = false;
  bool _saveCredentials = false;
  late LatLng _userLocation;
  Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _restaurantNameController.addListener(_checkName);
    _userLocation = LatLng(
      widget.ownerInfo?.latitude ?? 35.5399434,
      widget.ownerInfo?.longitude ?? 33.8748934,
    );
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _passwordController.dispose();
    _numberController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _checkName() async {
    String enteredName = _restaurantNameController.text.trim();
    bool available =
        await FirebaseOperations.checkRestaurantNameExists(enteredName);
    setState(() {
      _restaurantNameAvailable = available;
      _passMessage = available ? '' : 'Enter a new password';
    });
  }

  Future<void> _updateUserLocation() async {
    try {
      LatLng location = await getUserLocation();
      setState(() {
        _userLocation = location;
      });
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _userLocation,
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      print("Error updating user location: $e");
      // Handle error or show a message to the user
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String name = _restaurantNameController.text;
      String phoneNumber = _numberController.text;
      String location = ''; // You need to implement getting the location
      try {
        // Upload image and get download URL
        final imageUrl = await FirebaseOperations()
            .uploadImage('Stores_images', name, _selectedImage!);

        // Save data to Firestore
        await FirebaseFirestore.instance.collection('owners').add({
          'name': name,
          'phoneNumber': phoneNumber,
          'location': location,
          'ownerImage': imageUrl,
          'password': '',
          'orderTime': '',
          'orderLocation': '',
        });

        // Clear the form fields
        _restaurantNameController.clear();
        _passwordController.clear();
        _numberController.clear();
        _rateController.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanelPage()),
        );
      } catch (error) {
        print('Error submitting form: $error');
        // Handle error (show a message, log, etc.)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Log in to enter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 30),
                ProfilePic(
                  onPickImage: (File pickedImage) {
                    _selectedImage = pickedImage;
                  },
                  imageUrl: '',
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _restaurantNameController,
                  onChanged: (_) => _checkName(),
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name',
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                    suffixIcon: _restaurantNameAvailable
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _passMessage.isNotEmpty ? _passMessage : '',
                  ),
                ),
                // const SizedBox(height: 16.0),
                Visibility(
                  visible: !_restaurantNameAvailable,
                  child: TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: 'Number'),
                  ),
                ),
                // const SizedBox(height: 16.0),
                Visibility(
                  visible: !_restaurantNameAvailable,
                  child: TextFormField(
                    controller: _rateController,
                    decoration: const InputDecoration(labelText: 'Rate'),
                  ),
                ),
                const SizedBox(height: 16.0),
                Visibility(
                  visible: !_restaurantNameAvailable,
                  child: SizedBox(
                    height: 200,
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                      },
                      initialCameraPosition: CameraPosition(
                        target: _userLocation,
                        zoom: 15.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("userLocation"),
                          position: _userLocation,
                          infoWindow: const InfoWindow(title: "User Location"),
                        ),
                      },
                      gestureRecognizers: <Factory<
                          OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: !_restaurantNameAvailable,
                  child: ElevatedButton(
                    onPressed: _updateUserLocation,
                    child: const Text("Get My Location"),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Checkbox(
                      value: _saveCredentials,
                      onChanged: (value) {
                        setState(() {
                          _saveCredentials = value!;
                        });
                      },
                    ),
                    const Text('Save Credentials'),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

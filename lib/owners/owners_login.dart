import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/helpers/form_helper.dart';
import 'package:pixandrix/helpers/loader.dart';
import 'package:pixandrix/helpers/location_helper.dart';
import 'package:pixandrix/helpers/profile_pic.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';

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
  final String _passMessage = '';
  bool _restaurantNameAvailable = false;
  bool _saveCredentials = false;
  LatLng? userLocation;
  final Completer<GoogleMapController> _mapController = Completer();
  final GlobalLoader _globalLoader = GlobalLoader();

  @override
  void initState() {
    super.initState();
    _restaurantNameController.addListener(_checkName);
    userLocation = LatLng(
      widget.ownerInfo?.latitude ?? 33.8657637,
      widget.ownerInfo?.longitude ?? 35.5203407,
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
      // _passMessage = available ? '' : 'Enter a new password';
    });
  }

  Future<void> _updateUserLocation() async {
    try {
      LatLng location = await getUserLocation();
      setState(() {
        userLocation = location;
      });
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
             target: LatLng(
                  userLocation!.latitude,
                  userLocation!.longitude,
                ),
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
    _globalLoader.showLoader(context);
  if (_formKey.currentState!.validate()) {
    String name = _restaurantNameController.text;
    String phoneNumber = _numberController.text;
    String password = _passwordController.text;
    String rate = _rateController.text; // You need to implement getting the location
    try {
      // Upload image and get download URL
      final imageUrl = await FirebaseOperations().uploadImage('Stores_images', name, _selectedImage!);

      await submitFormStore(
        name: name,
        phoneNumber: phoneNumber,
        latitude: userLocation?.latitude,
          longitude: userLocation?.longitude, // Pass location as a string
        imageUrl: imageUrl,
        selectedImage: _selectedImage!,
        context: context,
        password: password,
        rate: rate,
      );
      _globalLoader.hideLoader();
    } catch (error) {
      showAlertDialog(
      context,
      'Error',
      'Enter all the information',
    );
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
                  'Enter you information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 30),
                Visibility(
                  visible: !_restaurantNameAvailable,
                  child: ProfilePic(
                  onPickImage: (File pickedImage) {
                    _selectedImage = pickedImage;
                  },
                  imageUrl: '',
                ),
            ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _restaurantNameController,
                  onChanged: (_) => _checkName(),
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name *',
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                    suffixIcon: _restaurantNameAvailable
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        :null
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    errorText: _passMessage.isNotEmpty ? _passMessage : null,
                  ),
                ),
                // const SizedBox(height: 16.0),
                Visibility(
                  visible: !_restaurantNameAvailable,
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: 'Number*'),
                  ),
                ),
                // const SizedBox(height: 16.0),
                Visibility(
                  visible: !_restaurantNameAvailable,
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _rateController,
                    decoration: const InputDecoration(labelText: 'Rate*'),
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
                        target: LatLng(
                  userLocation!.latitude,
                  userLocation!.longitude,
                ),
                        zoom: 15.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("userLocation"),
                          position: LatLng(
                  userLocation!.latitude,
                  userLocation!.longitude,
                ),
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

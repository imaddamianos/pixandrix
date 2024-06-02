import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/form_helper.dart';
import 'package:pixandrix/helpers/loader.dart';
import 'package:pixandrix/helpers/location_helper.dart';
import 'package:pixandrix/helpers/profile_pic.dart';
import 'package:pixandrix/helpers/secure_storage.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/owners/owners_home_page.dart';

final _secureStorage = SecureStorage();

class StoreLoginPage extends StatefulWidget {
  const StoreLoginPage({super.key, this.ownerLoginInfo});
  final OwnerData? ownerLoginInfo;

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
  LatLng? userLocation = const LatLng(33.8657637, 35.5203407);
  final GlobalLoader _globalLoader = GlobalLoader();
  bool? remember = true;
  late GoogleMapController _mapController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _isLoading = false;
  }

  Future<void> _loadSavedCredentials() async {
    final savedOwner = await _secureStorage.getOnwer();
    final savedPassword = await _secureStorage.getOwnerPassword();
    if (savedOwner != null) {
      // Set the text controllers with saved credentials
      _restaurantNameController.text = savedOwner;
      _passwordController.text = savedPassword!;
      _restaurantNameAvailable = true;
      setState(() {
        remember = true;
      });
    }
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
    });
  }

  Future<void> _updateUserLocation() async {
    try {
      LatLng location = await getUserLocation();
      setState(() {
        userLocation = location;
      });
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(userLocation!.latitude, userLocation!.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      print("Error updating user location: $e");
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    _globalLoader.showLoader(context);

    if (_formKey.currentState!.validate()) {
      String name = _restaurantNameController.text;
      String phoneNumber = _numberController.text;
      String password = _passwordController.text;
      String rate = _rateController.text;
      try {
        final imageUrl = await FirebaseOperations()
            .uploadImage('Stores_images', name, _selectedImage!);
        await submitFormStore(
          name: name,
          phoneNumber: phoneNumber,
          imageUrl: imageUrl,
          selectedImage: _selectedImage!,
          context: context,
          password: password,
          rate: rate,
          olatitude: userLocation!.latitude,
          olongitude: userLocation!.longitude,
          verified: false,
          isAvailable: false,
        );
      } catch (error) {
        showAlertDialog(
          context,
          'Error',
          'Enter all the information',
        );
      }
    }

    _globalLoader.hideLoader();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _ownerLogIn() async {
  setState(() {
    _isLoading = true;
  });

  if (_formKey.currentState!.validate()) {
    String name = _restaurantNameController.text;
    String password = _passwordController.text;
    try {
      OwnerData? ownerAuth = await FirebaseOperations.checkOwnerCredentials('owners', name, password);
      FirebaseOperations.addTokentoUsers(name, '');
      final verification = await FirebaseOperations.checkOwnerVerification(name);

      if (verification) {
        if (ownerAuth != null) {
          if (remember == true) {
            _secureStorage.saveOwner(name, password);
            _secureStorage.saveOwnerInfo(ownerAuth); // Save OwnerData
          }
          
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OwnersHomePage(ownerInfo: ownerAuth),
            ),
          );
          print('Login successful for owner: $name');
        } else {
          showAlertDialog(
            context,
            'Error',
            'Wrong password',
          );
        }
      } else {
        showAlertDialog(
          context,
          'Error',
          'Check verification with admin',
        );
      }
    } catch (error) {
      print('Error submitting form: $error');
    }
  }

  setState(() {
    _isLoading = false;
  });
}

  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      userLocation = tappedPoint;
    });
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: tappedPoint, zoom: 15.0),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // This widget will intercept the back button press
      onWillPop: () async {
        // Return false to prevent the back button action
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Store Login'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FirstPage()),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Enter your information',
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
                          errorText:
                              _errorMessage.isNotEmpty ? _errorMessage : null,
                          suffixIcon: _restaurantNameAvailable
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : null,
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
                      Visibility(
                        visible: !_restaurantNameAvailable,
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          controller: _numberController,
                          decoration: const InputDecoration(labelText: 'Number*'),
                        ),
                      ),
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
                              _mapController = controller;
                            },
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  userLocation!.latitude, userLocation!.longitude),
                              zoom: 15.0,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId("userLocation"),
                                position: LatLng(userLocation!.latitude,
                                    userLocation!.longitude),
                                infoWindow:
                                    const InfoWindow(title: "Current Location"),
                              ),
                            },
                            onTap: _onMapTapped,
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
                            value: remember,
                            activeColor: const Color.fromARGB(255, 255, 0, 0),
                            onChanged: (value) {
                              setState(() {
                                remember = value;
                                if (value == true) {
                                  _secureStorage.saveOwner(
                                    _restaurantNameController.text,
                                    _passwordController.text,
                                  );
                                } else {
                                  _secureStorage.clearEmailAndPassword();
                                }
                              });
                            },
                          ),
                          const Text('Save Credentials'),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_restaurantNameAvailable) {
                                  _ownerLogIn();
                                } else {
                                  _submitForm();
                                }
                              },
                        child:
                        _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}

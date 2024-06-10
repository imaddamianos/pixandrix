import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixandrix/drivers/drivers_home_page.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/form_helper.dart';
import 'package:pixandrix/helpers/image_id.dart';
import 'package:pixandrix/helpers/loader.dart';
import 'package:pixandrix/helpers/profile_pic.dart';
import 'package:pixandrix/helpers/alert_dialog.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/helpers/secure_storage.dart';

final _secureStorage = SecureStorage();

class DriversLoginPage extends StatefulWidget {
  const DriversLoginPage({super.key, this.driverInfo});
  final DriverData? driverInfo;

  @override
  _DriversLoginPageState createState() => _DriversLoginPageState();
}

class _DriversLoginPageState extends State<DriversLoginPage> {
  late File? _selectedImage;
  File? _selectedIDImage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final String _errorMessage = '';
  final String _passMessage = '';
  bool _driverNameAvailable = false;
  final GlobalLoader _globalLoader = GlobalLoader();
  bool? remember = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _driverNameController.addListener(_checkName);
    _loadSavedCredentials();
    _isLoading = false;
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _passwordController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final savedOwner = await _secureStorage.getDriver();
    final savedPassword = await _secureStorage.getDriverPassword();
    if (savedOwner != null) {
      _driverNameController.text = savedOwner;
      _passwordController.text = savedPassword!;
      _driverNameAvailable = true;
      setState(() {
        remember = true;
      });
    }
  }

  void _checkName() async {
    String enteredName = _driverNameController.text.trim();
    bool available = await FirebaseOperations.checkDriverNameExists(enteredName);
    setState(() {
      _driverNameAvailable = available;
    });
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    _globalLoader.showLoader(context);
    if (_formKey.currentState!.validate()) {
      String name = _driverNameController.text;
      String phoneNumber = _numberController.text;
      String password = _passwordController.text;
      try {
        // Upload image and get download URL
        final imageUrl = await FirebaseOperations().uploadImage('Drivers_images', name, _selectedImage!);
        final imageIdUrl = await FirebaseOperations().uploadImage('Drivers_ID', name, _selectedIDImage!);

        await submitFormDriver(
          name: name,
          phoneNumber: phoneNumber,
          imageUrl: imageUrl,
          selectedImage: _selectedImage!,
          context: context,
          password: password,
          imageIDUrl: imageIdUrl,
          verified: false,
          isAvailable: false,
        );
      } catch (error) {
        showAlertDialog(context, 'Error', 'Enter all the information');
      }
    }
    _globalLoader.hideLoader();
    setState(() {
      _isLoading = false;
    });
  }
  

  Future<void> _driverLogIn() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      String name = _driverNameController.text;
      String password = _passwordController.text;
      try {
        final driverAuth = await FirebaseOperations.checkDriverCredentials('drivers', name, password);
        final verification = await FirebaseOperations.checkDriverVerification(name);

        if (verification) {
          if (driverAuth != null) {
            if (remember == true) {
              // Save credentials only if the checkbox is selected
              _secureStorage.saveDriver(name, password);
              // Subscribe to notifications
              FirebaseOperations.addTokentoUsers('', name);
            }
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DriversHomePage(driverInfo: driverAuth),
              ),
            );
            print('Login successful for driver: $name');
          } else {
            showAlertDialog(context, 'Error', 'Wrong password');
          }
        } else {
          showAlertDialog(context, 'Error', 'Check verification with admin');
        }
      } catch (error) {
        print('Error submitting form: $error');
      }
    }
    setState(() {
      _isLoading = false;
    });
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
          title: const Text('Driver Login'),
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
                        visible: !_driverNameAvailable,
                        child: ProfilePic(
                          onPickImage: (File pickedImage) {
                            _selectedImage = pickedImage;
                          },
                          imageUrl: '',
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _driverNameController,
                        onChanged: (_) => _checkName(),
                        decoration: InputDecoration(
                          labelText: 'Driver Name *',
                          errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                          suffixIcon: _driverNameAvailable
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
                        visible: !_driverNameAvailable,
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          controller: _numberController,
                          decoration: const InputDecoration(labelText: 'Number*'),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Visibility(
                        visible: !_driverNameAvailable,
                        child: const Text('Upload your ID'),
                      ),
                      const SizedBox(height: 16.0),
                      Visibility(
                        visible: !_driverNameAvailable,
                        child: PersonalIdUploader(
                          onPickImage: (File pickedImage) {
                            _selectedIDImage = pickedImage;
                          },
                          imageUrl: '',
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
                                remember = value!;
                              });
                            },
                          ),
                          const Text('Save Credentials'),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_driverNameAvailable) {
                            _driverLogIn();
                          } else {
                            _submitForm();
                          }
                        },
                        child: _isLoading
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

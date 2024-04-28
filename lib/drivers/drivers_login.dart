import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixandrix/drivers/drivers_home_page.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
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

  @override
  void initState() {
    super.initState();
    _driverNameController.addListener(_checkName);
    _loadSavedCredentials();
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
    bool available =
        await FirebaseOperations.checkDriverNameExists(enteredName);
    setState(() {
      _driverNameAvailable = available;
    });
  }

  Future<void> _submitForm() async {
    _globalLoader.showLoader(context);
    if (_formKey.currentState!.validate()) {
      String name = _driverNameController.text;
      String phoneNumber = _numberController.text;
      String password = _passwordController.text;
      try {
        // Upload image and get download URL
        final imageUrl = await FirebaseOperations()
            .uploadImage('Drivers_images', name, _selectedImage!);
        final imageIdUrl = await FirebaseOperations()
            .uploadImage('Drivers_ID', name, _selectedIDImage!);

        await submitFormDriver(
          name: name,
          phoneNumber: phoneNumber,
          imageUrl: imageUrl,
          selectedImage: _selectedImage!,
          context: context,
          password: password,
          imageIDUrl: imageIdUrl,
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

 Future<void> _driverLogIn() async {
    if (_formKey.currentState!.validate()) {
      String name = _driverNameController.text;
      String password = _passwordController.text;

      try {
        final driverAuth = await FirebaseOperations.checkLoginCredentials('drivers', name, password);
        if (driverAuth != null) {
          if (remember == true) {
            // Save credentials only if the checkbox is selected
            _secureStorage.saveDriver(name, password);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriversHomePage(driverInfo: driverAuth)),
          );
          print('Login successful for owner: $name');
        } else {
          showAlertDialog(
            context,
            'Error',
            'Wrong password',
          );
        }
      } catch (error) {
        print('Error submitting form: $error');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Login'),
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
                      errorText:
                          _errorMessage.isNotEmpty ? _errorMessage : null,
                      suffixIcon: _driverNameAvailable
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : null),
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
                  child:const Text('upload your ID'),
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

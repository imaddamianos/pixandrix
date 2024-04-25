import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonalIdUploader extends StatefulWidget {
  const PersonalIdUploader({
    super.key,
    required this.onPickImage,
    required this.imageUrl,
  });

  final void Function(File pickedImage) onPickImage;
  final String imageUrl;

  @override
  _PersonalIdUploaderState createState() => _PersonalIdUploaderState();
}

class _PersonalIdUploaderState extends State<PersonalIdUploader> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 150,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        widget.onPickImage(_image!);
      }
    } catch (error) {
      print('Error picking image: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 230,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Container(
  decoration: BoxDecoration(
    shape: BoxShape.rectangle,
    image: DecorationImage(
      fit: BoxFit.cover,
      image: _image != null
          ? FileImage(_image!) as ImageProvider<Object>
          : NetworkImage(widget.imageUrl),
    ),
  ),
),

          Positioned(
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFFF5F6F9),
                      ),
                      onPressed: () async {
                        await _showImageSourceDialog();
                      },
                      child: const Icon(Icons.upload),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Image Source"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text("Gallery"),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text("Camera"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

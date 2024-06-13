import 'package:flutter/material.dart';

class SoundSelectionPage extends StatefulWidget {
  const SoundSelectionPage({super.key});

  @override
  _SoundSelectionPageState createState() => _SoundSelectionPageState();
}

class _SoundSelectionPageState extends State<SoundSelectionPage> {
  String selectedSound = 'collectring.mp3'; // Default selected sound
  

  // List of available sounds
  List<String> sounds = [
    'collectring.mp3',
    'digitalphonering.mp3',
    // Add more sounds as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Notification Sound'),
      ),
      body: ListView.builder(
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          String sound = sounds[index];
          return ListTile(
            title: Text(sound),
            leading: Radio(
              value: sound,
              groupValue: selectedSound,
              onChanged: (value) {
                setState(() {
                  selectedSound = value!;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Pass back the selected sound to the previous page
          Navigator.pop(context, selectedSound);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundSelectionPage extends StatefulWidget {
  const SoundSelectionPage({super.key});

  @override
  _SoundSelectionPageState createState() => _SoundSelectionPageState();
}

class _SoundSelectionPageState extends State<SoundSelectionPage> {
  String selectedSound = 'collectring.mp3'; // Default selected sound
  String customSoundPath = ''; // Custom sound path

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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                String sound = sounds[index];
                return ListTile(
                  title: Text(sound, style: const TextStyle(color: Colors.white)),
                  leading: Radio(
                    value: sound,
                    activeColor: Colors.red,
                    groupValue: selectedSound,
                    onChanged: (value) {
                      setState(() {
                        selectedSound = value!;
                        customSoundPath = '';
                        _playSound(selectedSound);
                        _saveSelectedSound(selectedSound);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
            leading: Radio(
              value: customSoundPath,
              activeColor: Colors.red,
              groupValue: selectedSound,
              onChanged: (value) {
                _pickSoundFromGallery();
              },
            ),
            onTap: _pickSoundFromGallery,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Pass back the selected sound to the previous page
          Navigator.pop(context, customSoundPath.isNotEmpty ? customSoundPath : selectedSound);
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  Future<void> _saveSelectedSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSound', sound);
  }

  void _playSound(String sound) {
    if (customSoundPath.isNotEmpty) {
      // Play the custom sound
      // Note: FlutterRingtonePlayer does not support playing arbitrary file paths
      // You might need to use a different plugin to play local files
      // Example: audioplayers package
    } else {
      switch (sound) {
        case 'collectring.mp3':
          FlutterRingtonePlayer.playRingtone(
            looping: false,
            volume: 0.1,
            asAlarm: false,
          );
          break;
        case 'digitalphonering.mp3':
          FlutterRingtonePlayer.playRingtone(
            looping: false,
            volume: 0.1,
            asAlarm: false,
          );
          break;
        // Add more cases for additional sounds
      }
    }
  }

  Future<void> _pickSoundFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        customSoundPath = result.files.single.path!;
        selectedSound = customSoundPath;
        _playSound(customSoundPath);
      });
    }
  }

  @override
  void dispose() {
    FlutterRingtonePlayer.stop();
    super.dispose();
  }
}

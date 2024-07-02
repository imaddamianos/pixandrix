import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:pixandrix/helpers/notification_bell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundSelectionPage extends StatefulWidget {
  const SoundSelectionPage({super.key});

  @override
  _SoundSelectionPageState createState() => _SoundSelectionPageState();
}

class _SoundSelectionPageState extends State<SoundSelectionPage> {
  String selectedSound = 'digitalphonering.mp3'; // Default selected sound

  // List of available sounds
  List<String> sounds = [
    'collectring.mp3',
    'digitalphonering.mp3',
    // Add more sounds as needed
  ];

  @override
  void initState() {
    super.initState();
    loadSelectedSound();
  }

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
                        NotificationService.selectedSound = selectedSound;
                        _playSound(selectedSound);
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      selectedSound = sound;
                      NotificationService.selectedSound = selectedSound;
                      _playSound(selectedSound);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveSelectedSound(selectedSound);
          Navigator.pop(context, selectedSound);
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  Future<void> _saveSelectedSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSound', sound);
  }

  Future<void> loadSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSound = prefs.getString('selectedSound') ?? 'collectring.mp3';
    });
  }

  void _playSound(String sound) {
    // Stop any currently playing sound
    FlutterRingtonePlayer.stop();

    // Play the new selected sound
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
      default:
        FlutterRingtonePlayer.playRingtone(
          looping: false,
          volume: 0.1,
          asAlarm: false,
        );
        break;
    }
  }

  @override
  void dispose() {
    // Stop the ringtone when disposing the widget
    FlutterRingtonePlayer.stop();
    super.dispose();
  }
}

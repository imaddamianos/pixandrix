import 'package:flutter/material.dart';
import 'package:pixandrix/helpers/notification_bell.dart';
import 'package:pixandrix/sound_selection_page.dart';
import 'package:pixandrix/volume_control_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedSound = 'Select Ringtone';

  @override
  void initState() {
    super.initState();
    _loadSelectedSound();
  }

  Future<void> _loadSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSound = prefs.getString('selectedSound')!;
      NotificationService.selectedSound = prefs.getString('selectedSound');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Sound',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            ListTile(
              title: const Text('Volume', style: TextStyle(color: Colors.white),),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white,),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VolumeControlPage(),
                  ),
                );
              },
            ),
            const Divider(),
            const Text(
              'Ringtone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            ListTile(
              title: Text(selectedSound, style: const TextStyle(color: Colors.white),),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white,),
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SoundSelectionPage(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    selectedSound = result;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

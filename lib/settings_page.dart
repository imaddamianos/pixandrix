// settings_page.dart
import 'package:flutter/material.dart';
import 'package:pixandrix/sound_selection_page.dart';
import 'package:pixandrix/volume_control_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              title: const Text('Select Ringtone'), textColor: Colors.white,
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white,),
              onTap: () {
               Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SoundSelectionPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

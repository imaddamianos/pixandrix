// settings_page.dart
import 'package:flutter/material.dart';

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Select Notification Sound'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Implement functionality to change notification sound
              },
            ),
            const Divider(),
            const Text(
              'Ringtone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Select Ringtone'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Implement functionality to change ringtone
              },
            ),
          ],
        ),
      ),
    );
  }
}

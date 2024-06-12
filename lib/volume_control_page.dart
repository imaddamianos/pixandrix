import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class VolumeControlPage extends StatefulWidget {
  @override
  _VolumeControlPageState createState() => _VolumeControlPageState();
}

class _VolumeControlPageState extends State<VolumeControlPage> {
  double _currentVolume = 0.0;

  @override
  void initState() {
    super.initState();
    _getVolume();
  }

  Future<void> _getVolume() async {
    double? volume = await FlutterVolumeController.getVolume();
    setState(() {
      _currentVolume = volume!;
    });
  }

  Future<void> _setVolume(double volume) async {
    await FlutterVolumeController.setVolume(volume);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Volume Control'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text('Adjust Notification Volume'),
            Slider(
              value: _currentVolume,
              min: 0,
              max: 1,
              divisions: 100,
              label: (_currentVolume * 100).toStringAsFixed(0),
              onChanged: (double value) {
                setState(() {
                  _currentVolume = value;
                  _setVolume(_currentVolume);
                });
              },
            ),
            Text('Volume: ${(_currentVolume * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}

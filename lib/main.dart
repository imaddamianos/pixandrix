import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_options.dart';
import 'package:pixandrix/helpers/notification_bell.dart';
import 'package:pixandrix/splash_screen.dart';
import 'package:pixandrix/theme/custom_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
await _loadSelectedSound();
  runApp(const MyApp());
}

Future<void> _loadSelectedSound() async {
  final prefs = await SharedPreferences.getInstance();
  NotificationService.selectedSound = prefs.getString('selectedSound') ?? '';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: customTheme,
      home: SplashScreen(),
    );
  }
}

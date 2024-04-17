import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pixandrix/firebase_options.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/theme/custom_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: customTheme,
      home: const FirstPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/theme/custom_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: customTheme,
      home: const FirstPage(),
    );
  }
}

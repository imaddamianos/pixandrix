import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 101, 101)).copyWith(background: Colors.black),
      ),
      home: FirstPage(),
    );
  }
}

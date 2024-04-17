import 'package:flutter/material.dart';

// Define custom theme colors
const Color primaryColor = Colors.blue;
const Color accentColor = Colors.green;
const Color backgroundColor = Color.fromARGB(255, 0, 0, 0);
const Color textColor = Color.fromARGB(255, 255, 255, 255);
const Color placeholderColor = Color.fromARGB(159, 255, 255, 255);

// Define custom theme
final ThemeData customTheme = ThemeData(
  primaryColor: primaryColor,
  hintColor: accentColor,
  scaffoldBackgroundColor: backgroundColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: textColor),
    bodyMedium: TextStyle(color: textColor),
    titleLarge: TextStyle(color: textColor),
    
    // Add more text styles as needed
  ),
  inputDecorationTheme: const InputDecorationTheme(
    hintStyle: TextStyle(color: placeholderColor),
    
  ), 
  // colorScheme: ColorScheme(background: backgroundColor, brightness: null, primary: null, onPrimary: null),
);

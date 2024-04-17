import 'package:flutter/material.dart';

// Define custom theme colors
const Color primaryColor = Colors.blue;
const Color accentColor = Colors.green;
const Color backgroundColor = Color.fromARGB(255, 0, 0, 0);
const Color textColor = Color.fromARGB(255, 255, 255, 255);
const Color placeholderColor = Color.fromARGB(150, 255, 255, 255); // Adjust opacity as needed
const Color highlightColor = Colors.green; // Define the color when highlighting

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
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Color.fromARGB(255, 54, 251, 0), // Change the selected item color
    unselectedItemColor: Colors.grey, // Change the unselected item color
    selectedLabelStyle: TextStyle(color: Color.fromARGB(101, 255, 0, 0)), // Change the selected label color
    unselectedLabelStyle: TextStyle(color: Colors.grey), // Change the unselected label color
    // Define selected background color
    backgroundColor: Colors.red, // Set your desired selected background color
  ),
);

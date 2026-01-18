import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.purple,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color.fromARGB(255, 15, 15, 20),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          color: Color.fromARGB(255, 150, 150, 255),
          fontSize: 16,
        ),
      ),
    );
  }

  static const Color primaryColor = Colors.purple;
  static const Color backgroundColor = Color.fromARGB(255, 15, 15, 20);
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color.fromARGB(255, 150, 150, 255);
}

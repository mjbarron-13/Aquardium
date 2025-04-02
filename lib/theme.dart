import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0077B6);
  static const Color secondaryColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF48CAE4);
  static const Color warningColor = Color(0xFFFFD166);
  static const Color dangerColor = Color(0xFFD62828);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(fontFamily: 'Quicksand', fontSize: 16, color: Colors.black54),
      titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

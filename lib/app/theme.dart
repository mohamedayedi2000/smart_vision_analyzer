import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFF2563EB),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF10B981),
      surface: Colors.white,
    ),
    useMaterial3: true,
    fontFamily: 'Poppins',
  );

  static final darkTheme = ThemeData(
    primaryColor: const Color(0xFF2563EB),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF10B981),
      surface: Color(0xFF121212),
    ),
    useMaterial3: true,
    fontFamily: 'Poppins',
  );
}
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 37, 115, 151),
          secondary: Color(0xFF4CAF50),
          tertiary: Color(0xFFFF9800),
          primaryContainer: Color(0xFFECEFF1),
          secondaryContainer: Color(0xFFE8F5E9),
          tertiaryContainer: Color.fromARGB(255, 253, 206, 52),
        ),
        scaffoldBackgroundColor: const Color(0xFFEEF1F5),
      );
}

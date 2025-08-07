import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = 'http://localhost:8080/api';
}

class AppColors {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color surfaceColor = Color(0xFFF5F5F5);
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle body1 = TextStyle(fontSize: 16, color: Colors.black87);

  static const TextStyle body2 = TextStyle(fontSize: 14, color: Colors.black54);
}

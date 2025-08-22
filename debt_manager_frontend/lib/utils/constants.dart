import 'package:flutter/material.dart';

class AppConstants {
  //static const String baseUrl = 'http://localhost:8080/api';
  static const baseUrl = "http://192.168.2.119:8080/api";
}

class AppColors {
  // Modern gradient colors inspired by the reference
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color primaryOrange = Color(0xFFFF8A65);
  static const Color deepPink = Color(0xFFE91E63);
  static const Color lightOrange = Color(0xFFFFAB91);

  // Supporting colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D3748);
  static const Color lightText = Color(0xFF718096);
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color shadowColor = Color(0x1A000000);

  // Status colors
  static const Color successColor = Color(0xFF48BB78);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color warningColor = Color(0xFFED8936);
  static const Color infoColor = Color(0xFF4299E1);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPink, primaryOrange],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF5F5), Color(0xFFFFF8F0)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF5F5), Color(0xFFFFFFFF)],
  );
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
    letterSpacing: -0.3,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkText,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.lightText,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.lightText,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

class AppShadows {
  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.shadowColor,
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: AppColors.shadowColor,
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );
}

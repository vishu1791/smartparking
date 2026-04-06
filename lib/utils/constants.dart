import 'package:flutter/material.dart';

class AppConstants {
  static const double hourlyRate = 10.0;

  // Premium Color Palette
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42C8);
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF252542);
  static const Color textLight = Color(0xFF2C3E50);
  static const Color textDark = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF7F8C8D);

  // Status Colors (Soft Variants)
  static const Color availableColor = Color(0xFF2ECC71); // Soft Green
  static const Color availableLight = Color(0xFFE8F8F5);
  static const Color occupiedColor = Color(0xFFE74C3C); // Soft Red
  static const Color occupiedLight = Color(0xFFFDEDEC);
  static const Color reservedColor = Color(0xFFF39C12); // Warm Amber
  static const Color reservedLight = Color(0xFFFEF5E7);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8E84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient availableGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF58D68D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient occupiedGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFEC7063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient reservedGradient = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFF5B041)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
}

import 'package:flutter/material.dart';

class AppColors {
  // --- Dark First Core Palette ---
  static const Color darkBackground = Color(0xFF0B0D12);
  static const Color darkCard = Color(0xFF14171F);
  static const Color darkElevated = Color(0xFF1B1F2A);
  
  // Borders & Dividers
  static const Color borderSubtle = Color(0x0FFFFFFF); // White at 6% opacity
  static const Color borderSubtleLight = Color(0x14000000); // Black at 8% opacity

  // Primary Gradient Colors
  static const Color gradientStart = Color(0xFF6C7BFF); // Indigo
  static const Color gradientEnd = Color(0xFF9B6CFF);   // Violet
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status Colors
  static const Color completedGreen = Color(0xFF3DDC97);
  static const Color restAmber = Color(0xFFFFB800);
  static const Color destructiveRed = Color(0xFFFF5252);

  // --- Light Palette Fallback ---
  static const Color primary = Color(0xFF6C7BFF);
  static const Color secondary = Color(0xFF9B6CFF);
  static const Color success = Color(0xFF3DDC97);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF5252);
  
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF12141D);
  static const Color onSurfaceVariant = Color(0xFF65697B);
  static const Color outline = Color(0xFFE2E6EE);

  // --- Dark Palette Scheme Mappings ---
  static const Color primaryDark = Color(0xFF6C7BFF);
  static const Color darkSurface = Color(0xFF14171F);
  static const Color darkSurfaceVariant = Color(0xFF1B1F2A);
  static const Color darkOnSurface = Color(0xFFF0F2F8);
  static const Color darkOnSurfaceVariant = Color(0xFF8A8F9E);
  static const Color darkOutline = Color(0x1AFFFFFF);

  // Legacy
  static const Color primaryBlue = Color(0xFF6C7BFF);
}

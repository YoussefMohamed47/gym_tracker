import 'package:flutter/material.dart';

/// Shared athletic design system. All existing semantic names are retained so
/// report exports and legacy widgets consume the same palette.
class AppColors {
  static const darkBackground = Color(0xFF090E12);
  static const darkCard = Color(0xFF121B20);
  static const darkElevated = Color(0xFF1C292D);
  static const borderSubtle = Color(0x22B9C8C3);
  static const borderSubtleLight = Color(0x1B18251E);
  static const gradientStart = Color(0xFFC7F476);
  static const gradientEnd = Color(0xFFA4E3A0);
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF3A7052), Color(0xFF1E514A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const completedGreen = Color(0xFF76DDAB);
  static const restAmber = Color(0xFFF8C575);
  static const warningAmber = restAmber;
  static const destructiveRed = Color(0xFFFF777C);
  static const indigoAccent = gradientStart;
  static const violetAccent = Color(0xFF99B8EF);
  static const textPrimary = Color(0xFFF0F4EE);
  static const textSecondary = Color(0xFF9BAEA9);
  static const textMuted = Color(0xFF6B8280);
  static const primary = Color(0xFF426D35);
  static const secondary = Color(0xFF56886A);
  static const success = completedGreen;
  static const warning = restAmber;
  static const error = destructiveRed;
  static const background = Color(0xFFF0F4EF);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF13221F);
  static const onSurfaceVariant = Color(0xFF64776F);
  static const outline = Color(0xFFD8E3DB);
  static const primaryDark = gradientStart;
  static const darkSurface = darkCard;
  static const darkSurfaceVariant = darkElevated;
  static const darkOnSurface = textPrimary;
  static const darkOnSurfaceVariant = textSecondary;
  static const darkOutline = borderSubtle;
  static const primaryBlue = gradientStart;
}

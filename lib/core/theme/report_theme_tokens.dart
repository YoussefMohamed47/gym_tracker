import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportThemeTokens {
  // Dark Premium Palette
  static const Color background = Color(0xFF0B0D12);
  static const Color cardBackground = Color(0xFF14171F);
  static const Color elevatedCard = Color(0xFF1B1F2A);
  
  // Borders & Dividers
  static const Color borderSubtle = Color(0x0FFFFFFF); // White @ 6%
  static const Color borderMedium = Color(0x1AFFFFFF); // White @ 10%
  
  // Brand Accent Gradient
  static const Color indigoAccent = Color(0xFF6C7BFF);
  static const Color violetAccent = Color(0xFF9B6CFF);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [indigoAccent, violetAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status Colors
  static const Color completedGreen = Color(0xFF3DDC97);
  static const Color warningAmber = Color(0xFFFFB800);
  static const Color destructiveRed = Color(0xFFFF5252);

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F2F8);
  static const Color textSecondary = Color(0xFF8A8F9E);
  static const Color textMuted = Color(0xFF555968);

  // Standard Radii
  static const double cardRadius = 20.0;
  static const double chipRadius = 12.0;
  static const double buttonRadius = 16.0;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);
  static BorderRadius get chipBorderRadius => BorderRadius.circular(chipRadius);

  // Typography - Arabic (Cairo / Noto Kufi Arabic)
  static TextStyle arabicHeader({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w800,
    Color color = textPrimary,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle arabicBody({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
    Color color = textPrimary,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.4,
    );
  }

  // Typography - Latin & Numbers (Outfit with Tabular Figures)
  static TextStyle outfitHeader({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w900,
    Color color = textPrimary,
    double letterSpacing = -0.5,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle outfitNumber({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w800,
    Color color = textPrimary,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle outfitSubtext({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = textSecondary,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

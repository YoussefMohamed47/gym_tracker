import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

/// Typography, radii and sheet surfaces. Palette colours come from
/// [AppColors], the single source of truth; the names here are kept so
/// existing widgets keep compiling.
class ReportThemeTokens {
  // Dark Premium Palette
  static const Color background = AppColors.darkBackground;
  static const Color cardBackground = AppColors.darkCard;
  static const Color elevatedCard = AppColors.darkElevated;

  /// White hairlines for dark glass cards and sheets. Not the same as
  /// [AppColors.borderSubtle], which is the themed card border.
  static const Color glassBorder = Color(0x0FFFFFFF); // White @ 6%
  static const Color glassBorderStrong = Color(0x1AFFFFFF); // White @ 10%

  // Brand Accent Gradient
  static const Color indigoAccent = AppColors.indigoAccent;
  static const Color violetAccent = AppColors.violetAccent;

  static const LinearGradient primaryGradient = AppColors.primaryGradient;

  // Status Colors
  static const Color completedGreen = AppColors.completedGreen;
  static const Color warningAmber = AppColors.warningAmber;
  static const Color destructiveRed = AppColors.destructiveRed;

  // Text Colors
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;

  // Standard Radii & Dimensions
  static const double cardRadius = 22.0;
  static const double sheetRadius = 28.0;
  static const double chipRadius = 12.0;
  static const double buttonRadius = 16.0;
  static const double minTouchTarget = 48.0;
  static const double screenPadding = 16.0;
  static const double itemGap = 12.0;

  // Solid Semi-Transparent Elevated Surfaces (NO BLUR)
  static const Color sheetSurfaceDark = Color(0xF2121B20); // 95% #14171F
  static const Color sheetSurfaceLight = Color(0xF5FFFFFF);

  static BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);
  static BorderRadius get sheetBorderRadius =>
      BorderRadius.circular(sheetRadius);
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
    double? letterSpacing,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

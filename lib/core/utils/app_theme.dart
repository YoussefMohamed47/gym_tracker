import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => _createTheme(Brightness.light);
  static ThemeData get dark => _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.gradientStart,
      brightness: brightness,
      primary: isDark ? AppColors.gradientStart : AppColors.primary,
      secondary: AppColors.gradientEnd,
      surface: isDark ? AppColors.darkCard : AppColors.surface,
      surfaceContainerHigh: isDark ? AppColors.darkElevated : AppColors.surface,
      onSurface: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
      onSurfaceVariant: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
      error: AppColors.destructiveRed,
      outline: isDark ? AppColors.borderSubtle : AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      
      // Typography
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).copyWith(
        displayMedium: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight, 
            width: 1,
          ),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gradientStart,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

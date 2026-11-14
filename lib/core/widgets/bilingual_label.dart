import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A label shown in both languages the same way everywhere: Arabic as the
/// main line, English smaller in capitals underneath.
class BilingualLabel extends StatelessWidget {
  final String arabic;
  final String english;

  /// Size of the Arabic line; the English line is a fixed small caption.
  final double size;
  final FontWeight weight;
  final Color? color;

  const BilingualLabel({
    super.key,
    required this.arabic,
    required this.english,
    this.size = 14,
    this.weight = FontWeight.w800,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          arabic,
          style: GoogleFonts.cairo(
            fontSize: size,
            fontWeight: weight,
            height: 1.25,
            color: color ?? scheme.onSurface,
          ),
        ),
        Text(
          english.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

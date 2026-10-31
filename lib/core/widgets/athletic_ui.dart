import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A lightweight design vocabulary for the training, journal and archive views.
class AthleticSectionTitle extends StatelessWidget {
  final String number;
  final String title;
  final String? description;
  const AthleticSectionTitle({super.key, required this.number, required this.title, this.description});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: GoogleFonts.outfit(color: color.primary, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(width: 13),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.6, color: color.onSurface)),
              if (description != null) Text(description!, style: GoogleFonts.cairo(fontSize: 12, color: color.onSurfaceVariant)),
            ],
          )),
        ],
      ),
    );
  }
}

class AthleticMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const AthleticMetric({super.key, required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: colors.primary),
        const SizedBox(height: 12),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: colors.onSurface))),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.cairo(fontSize: 10, color: colors.onSurfaceVariant)),
      ],
    );
  }
}

class AthleticEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  const AthleticEmpty({super.key, required this.icon, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: colors.primary),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.cairo(fontSize: 12, color: colors.onSurfaceVariant)),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

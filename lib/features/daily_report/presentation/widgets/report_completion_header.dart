import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/model/daily_report.dart';

/// Full-bleed editorial progress hero, deliberately not a rounded summary card.
class ReportCompletionHeader extends StatelessWidget {
  final DailyReport report;
  const ReportCompletionHeader({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ratio = report.overallCompletionRatio.clamp(0.0, 1.0);
    final items = <(String, bool)>[
      ('FOOD', report.breakfast.isNotEmpty || report.lunch.isNotEmpty || report.dinner.isNotEmpty ||
          report.breakfastEntries.isNotEmpty || report.lunchEntries.isNotEmpty || report.dinnerEntries.isNotEmpty),
      ('WATER', report.water.trim().isNotEmpty),
      ('SLEEP', report.sleepTime.trim().isNotEmpty),
      ('TRAIN', report.training.trim().isNotEmpty),
      ('SUPPS', report.supplements.trim().isNotEmpty),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TODAY AT A GLANCE', style: GoogleFonts.outfit(color: colors.primary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.4)),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${(ratio * 100).round()}', style: GoogleFonts.outfit(color: colors.onSurface, fontSize: 78, fontWeight: FontWeight.w900, height: 0.95, letterSpacing: -5)),
          Padding(padding: const EdgeInsets.only(bottom: 7), child: Text('%', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: colors.primary))),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('DAILY', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, height: 0.9)),
              Text('LOGGED', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, height: 1.1, color: colors.onSurfaceVariant)),
            ]),
          ),
        ]),
        const SizedBox(height: 22),
        Row(children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              height: 6,
              decoration: BoxDecoration(
                color: items[i].$2 ? colors.primary : colors.outline.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
            )),
            if (i != items.length - 1) const SizedBox(width: 6),
          ],
        ]),
        const SizedBox(height: 8),
        Row(children: [
          for (final item in items)
            Expanded(child: Text(item.$1, textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800,
                color: item.$2 ? colors.primary : colors.onSurfaceVariant))),
        ]),
      ]),
    );
  }
}

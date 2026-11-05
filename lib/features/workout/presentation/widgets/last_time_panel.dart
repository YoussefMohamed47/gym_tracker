import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_set_log.dart';

/// Estimated one-rep max (Epley). Only meaningful for weighted sets.
double? estimatedOneRepMaxKg(Iterable<ExerciseSetLog> sets) {
  double? best;
  for (final s in sets) {
    final w = s.weightKg;
    final r = s.actualReps;
    if (w == null || r == null || w <= 0 || r <= 0) continue;
    final e = r == 1 ? w : w * (1 + r / 30);
    if (best == null || e > best) best = e;
  }
  return best;
}

/// "60", "62.5": whole numbers without ".0", like the set rows show them.
String formatWeight(double kg, WeightUnit unit) {
  final v = WeightConverter.convert(kg, WeightUnit.kg, unit);
  return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
}

String _w(double kg, WeightUnit unit) => formatWeight(kg, unit);

/// "Last time" for one exercise: what you lifted, its estimated 1RM, and how
/// today's performed sets compare, optionally with a copy action.
class LastTimePanel extends StatelessWidget {
  final String previousDate;
  final List<ExerciseSetLog> previousSets;
  final List<ExerciseSetLog> currentSets;
  final WeightUnit unit;
  final VoidCallback? onCopyPrevious;

  const LastTimePanel({
    super.key,
    required this.previousDate,
    required this.previousSets,
    required this.currentSets,
    required this.unit,
    this.onCopyPrevious,
  });

  String _summary() {
    final done = previousSets
        .where((s) => s.weightKg != null || s.actualReps != null)
        .toList();
    if (done.isEmpty) return '—';
    final weights = done.map((s) => s.weightKg).toSet();
    if (weights.length == 1 && weights.first != null) {
      final reps = done.map((s) => s.actualReps?.toString() ?? '–').join(', ');
      return '${_w(weights.first!, unit)} ${unit.name} × $reps';
    }
    return done
        .map(
          (s) =>
              '${s.weightKg == null ? '–' : _w(s.weightKg!, unit)}×${s.actualReps ?? '–'}',
        )
        .join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final before = estimatedOneRepMaxKg(previousSets);
    final today = estimatedOneRepMaxKg(currentSets.where((s) => s.isPerformed));
    final delta = (before != null && today != null) ? today - before : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST TIME · $previousDate',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _summary(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (before != null) ...[
                  const SizedBox(height: 3),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Est. 1RM ${_w(before, unit)} ${unit.name}',
                        ),
                        if (delta != null)
                          TextSpan(
                            text:
                                '  →  today ${_w(today!, unit)}'
                                ' (${delta >= 0 ? '+' : '−'}${_w(delta.abs(), unit)})',
                            style: TextStyle(
                              color: delta >= 0
                                  ? AppColors.completedGreen
                                  : AppColors.restAmber,
                            ),
                          ),
                      ],
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onCopyPrevious != null)
            TextButton.icon(
              onPressed: onCopyPrevious,
              icon: const Icon(
                Icons.electric_bolt_rounded,
                size: 14,
                color: AppColors.gradientStart,
              ),
              label: Text(
                'Copy',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gradientStart,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown under the sets when today's heaviest performed set beats last time.
class PrBanner extends StatelessWidget {
  final double newKg;
  final double oldKg;
  final WeightUnit unit;

  const PrBanner({
    super.key,
    required this.newKg,
    required this.oldKg,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.restAmber.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.restAmber.withValues(alpha: .45),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.restAmber,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New weight PR!',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.restAmber,
                      ),
                    ),
                    Text(
                      '${_w(newKg, unit)} ${unit.name} beats your last best of '
                      '${_w(oldKg, unit)} ${unit.name}',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: .2, end: 0, curve: Curves.easeOutCubic);
  }
}

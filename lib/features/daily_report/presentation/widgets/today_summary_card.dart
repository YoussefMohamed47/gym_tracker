import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../domain/model/daily_report.dart';
import '../../domain/model/meal_slot.dart';
import '../../domain/model/water_amount.dart';
import '../../domain/models/nutrition_insights.dart';

/// The first thing on the Nutrition screen: meals ring, water, supplements,
/// training type and the logging streak, all from today's report.
class TodaySummaryCard extends StatelessWidget {
  final DailyReport report;
  final NutritionInsights insights;
  final double waterTargetLiters;

  const TodaySummaryCard({
    super.key,
    required this.report,
    required this.insights,
    required this.waterTargetLiters,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logged = MealSlot.values.where((s) => s.isLogged(report)).length;
    final total = MealSlot.values.length;
    final water = WaterAmount.parseLiters(report.water) ?? 0;
    final waterRatio = waterTargetLiters <= 0
        ? 0.0
        : (water / waterTargetLiters).clamp(0.0, 1.0);
    final hasSupplements = report.supplements.trim().isNotEmpty;
    // Today counts as "active" in the week strip once anything is logged.
    final week = List<bool>.of(insights.lastSevenDays);
    final todayActive = week.isNotEmpty && (week.last || logged > 0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline.withValues(alpha: .35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1B2D25), AppColors.darkCard]
              : [scheme.primary.withValues(alpha: .10), scheme.surface],
        ),
      ),
      child: Row(
        children: [
          _MealsRing(logged: logged, total: total),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _line(
                  context,
                  icon: Icons.water_drop_rounded,
                  iconColor: AppColors.violetAccent,
                  label: 'Water',
                  value: '${_fmt(water)} / ${_fmt(waterTargetLiters)} L',
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: waterRatio,
                    color: AppColors.violetAccent,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),
                _line(
                  context,
                  icon: Icons.medication_rounded,
                  iconColor: hasSupplements
                      ? AppColors.completedGreen
                      : scheme.onSurfaceVariant,
                  label: 'Supplements',
                  value: hasSupplements ? '✓ Done' : '—',
                  valueColor: hasSupplements ? AppColors.completedGreen : null,
                ),
                if (report.training.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _line(
                    context,
                    icon: Icons.fitness_center_rounded,
                    iconColor: scheme.primary,
                    label: 'Training',
                    value: report.training,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: AppColors.restAmber,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        insights.streakDays == 1
                            ? '1-day streak'
                            : '${insights.streakDays}-day streak',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.restAmber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var i = 0; i < week.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color:
                                (i == week.length - 1 ? todayActive : week[i])
                                ? scheme.primary
                                : scheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    final r = (v * 10).round() / 10;
    return r == r.roundToDouble() ? r.toStringAsFixed(1) : r.toString();
  }

  Widget _line(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor ?? scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _MealsRing extends StatelessWidget {
  final int logged;
  final int total;
  const _MealsRing({required this.logged, required this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 92,
      height: 92,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: total == 0 ? 0 : logged / total),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => CustomPaint(
          painter: _RingPainter(
            value: value,
            track: scheme.surfaceContainerHighest,
            colors: [scheme.primary, AppColors.completedGreen],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$logged',
                        style: GoogleFonts.outfit(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: '/$total',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'MEALS',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color track;
  final List<Color> colors;
  _RingPainter({
    required this.value,
    required this.track,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 11.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (value <= 0) return;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: colors,
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.track != track || old.colors != colors;
}

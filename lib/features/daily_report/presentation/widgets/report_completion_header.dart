import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/model/daily_report.dart';

class ReportCompletionHeader extends StatelessWidget {
  final DailyReport report;

  const ReportCompletionHeader({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratio = report.overallCompletionRatio;
    final percentage = (ratio * 100).toInt();

    final hasMeals = report.breakfast.trim().isNotEmpty ||
        report.lunch.trim().isNotEmpty ||
        report.dinner.trim().isNotEmpty;
    final hasWater = report.water.trim().isNotEmpty;
    final hasSleep = report.sleepTime.trim().isNotEmpty;
    final hasTraining = report.training.trim().isNotEmpty;
    final hasSupplements = report.supplements.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.darkElevated.withValues(alpha: 0.8),
                        AppColors.darkCard.withValues(alpha: 0.95),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? AppColors.borderSubtle
                    : AppColors.outline.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.indigo).withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: percentage == 100
                                ? const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                                  )
                                : AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (percentage == 100
                                        ? Colors.orange
                                        : AppColors.gradientStart)
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            percentage == 100
                                ? Icons.auto_awesome_rounded
                                : Icons.bolt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              percentage == 100
                                  ? 'Daily Goal Accomplished! 🎉'
                                  : 'Daily Completion Status',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkOnSurface
                                    : AppColors.onSurface,
                              ),
                            ),
                            Text(
                              percentage == 100
                                  ? 'All logging goals completed today'
                                  : '$percentage% of daily items logged',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkOnSurfaceVariant
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gradientStart.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        '$percentage%',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: percentage == 100
                              ? const LinearGradient(
                                  colors: [Color(0xFF3DDC97), Color(0xFF20C997)],
                                )
                              : AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: (percentage == 100
                                      ? AppColors.completedGreen
                                      : AppColors.gradientStart)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPillBadge(context, 'Meals', Icons.restaurant_rounded, hasMeals, isDark),
                    _buildPillBadge(context, 'Water', Icons.water_drop_rounded, hasWater, isDark),
                    _buildPillBadge(context, 'Sleep', Icons.bedtime_rounded, hasSleep, isDark),
                    _buildPillBadge(context, 'Training', Icons.fitness_center_rounded, hasTraining, isDark),
                    _buildPillBadge(context, 'Supps', Icons.medication_rounded, hasSupplements, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillBadge(
    BuildContext context,
    String label,
    IconData icon,
    bool isDone,
    bool isDark,
  ) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.completedGreen.withValues(alpha: isDark ? 0.2 : 0.15)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04)),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone
                  ? AppColors.completedGreen
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: AppColors.completedGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Icon(
            isDone ? Icons.check_rounded : icon,
            size: 18,
            color: isDone
                ? AppColors.completedGreen
                : (isDark
                    ? AppColors.darkOnSurfaceVariant.withValues(alpha: 0.5)
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
            color: isDone
                ? (isDark ? AppColors.darkOnSurface : AppColors.onSurface)
                : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

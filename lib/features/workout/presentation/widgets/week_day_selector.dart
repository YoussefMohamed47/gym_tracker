import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/workout_type.dart';
import '../../utils/date_utils.dart';

class WeekDaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const WeekDaySelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final weekDays = WorkoutDateUtils.getWeekDays(selectedDate);
    final dayNameFormat = DateFormat('E'); // Mon, Tue...
    final dayNumberFormat = DateFormat('d');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedIndex = weekDays.indexWhere(
      (d) =>
          d.year == selectedDate.year &&
          d.month == selectedDate.month &&
          d.day == selectedDate.day,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.outline,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 7.0;

          return Stack(
            children: [
              // Animated Sliding Gradient Pill Indicator
              if (selectedIndex != -1)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * itemWidth,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientStart.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),

              // 7 Day Tap Buttons
              Row(
                children: weekDays.map((date) {
                  final isSelected =
                      date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;

                  final workoutType = WorkoutDateUtils.getWorkoutTypeForDay(date);
                  final isRestDay = workoutType == WorkoutType.rest;
                  final isPast = date.isBefore(
                    DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    ),
                  );

                  // Dot color: Green if completed/past, Accent if planned, Grey if rest
                  Color dotColor = Colors.grey.shade600;
                  if (!isRestDay) {
                    if (isPast) {
                      dotColor = AppColors.completedGreen;
                    } else {
                      dotColor = AppColors.gradientStart;
                    }
                  }

                  return Expanded(
                    child: SizedBox(
                      height: 64,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onDateSelected(date);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayNameFormat.format(date)[0], // M, T, W...
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dayNumberFormat.format(date),
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Status Dot
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.white : dotColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

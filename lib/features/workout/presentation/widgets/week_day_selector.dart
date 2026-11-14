import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_type.dart';
import '../../utils/date_utils.dart';

/// A horizontal date track, separate from the exercise workspace.
class WeekDaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  /// The open day's training; the bar under each other day shows where the
  /// 8-day rotation puts it (lime for training, grey for rest).
  final WorkoutType openType;

  const WeekDaySelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.openType,
  });

  /// Whole days from the open day to [day], ignoring the time of day.
  int _offsetFromOpenDay(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day)
          .difference(
            DateTime.utc(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
            ),
          )
          .inDays;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final week = WorkoutDateUtils.getWeekDays(selectedDate);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'THE WEEK',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  letterSpacing: 1.9,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMMM yyyy').format(selectedDate).toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final day in week)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final active =
                          day.year == selectedDate.year &&
                          day.month == selectedDate.month &&
                          day.day == selectedDate.day;
                      final projected = WorkoutCatalog.projectedType(
                        openType,
                        _offsetFromOpenDay(day),
                      );
                      final rest = projected == WorkoutType.rest;
                      final unknown = projected == null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Material(
                          color: active ? colors.primary : colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onDateSelected(day);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 72,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('E').format(day).substring(0, 1),
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: active
                                          ? colors.onPrimary
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${day.day}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: active
                                          ? colors.onPrimary
                                          : colors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    height: 3,
                                    width: 12,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? colors.onPrimary
                                          : unknown
                                          ? colors.primary.withValues(
                                              alpha: 0.3,
                                            )
                                          : rest
                                          ? colors.outline
                                          : colors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/workout_type.dart';
import '../../utils/date_utils.dart';

/// A horizontal date track, separate from the exercise workspace.
class WeekDaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  const WeekDaySelector({super.key, required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final week = WorkoutDateUtils.getWeekDays(selectedDate);
    return Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('THE WEEK', style: GoogleFonts.outfit(fontSize: 11, letterSpacing: 1.9,
            color: colors.onSurfaceVariant, fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(DateFormat('MMMM yyyy').format(selectedDate).toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: colors.primary)),
        ]),
        const SizedBox(height: 12),
        Row(children: [for (final day in week)
          Expanded(child: Builder(builder: (context) {
            final active = day.year == selectedDate.year && day.month == selectedDate.month && day.day == selectedDate.day;
            final rest = WorkoutDateUtils.getWorkoutTypeForDay(day) == WorkoutType.rest;
            return Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Material(
              color: active ? colors.primary : colors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () { HapticFeedback.selectionClick(); onDateSelected(day); },
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(height: 72, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(DateFormat('E').format(day).substring(0, 1),
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700,
                      color: active ? colors.onPrimary : colors.onSurfaceVariant)),
                  const SizedBox(height: 3),
                  Text('${day.day}', style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w900,
                    color: active ? colors.onPrimary : colors.onSurface)),
                  const SizedBox(height: 3),
                  Container(height: 3, width: 12, decoration: BoxDecoration(
                    color: active ? colors.onPrimary : rest ? colors.outline : colors.primary,
                    borderRadius: BorderRadius.circular(4))),
                ])),
              ),
            ));
          })),
        ]),
      ],
    ));
  }
}

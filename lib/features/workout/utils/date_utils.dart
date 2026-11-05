import 'package:intl/intl.dart';
import '../domain/entities/workout_type.dart';

class WorkoutDateUtils {
  static final DateFormat _dateKeyFormat = DateFormat('yyyy-MM-dd');

  /// Normalizes a DateTime to yyyy-MM-dd dateKey.
  static String formatDateKey(DateTime date) {
    return _dateKeyFormat.format(date);
  }

  /// Parses a dateKey back to DateTime.
  static DateTime parseDateKey(String dateKey) {
    return _dateKeyFormat.parse(dateKey);
  }

  /// Returns the Sunday-Saturday week range for a given date safely across DST transitions.
  static List<DateTime> getWeekDays(DateTime date) {
    // DateTime.weekday: Monday = 1, ..., Saturday = 6, Sunday = 7.
    // We want Sunday to be day 0 of the week.
    final daysSinceSunday = date.weekday % 7;
    // Normalize date to pure calendar date (year, month, day) first to avoid DST hour shift!
    final pureDate = DateTime(date.year, date.month, date.day);
    final sunday = pureDate.subtract(Duration(days: daysSinceSunday));

    // Construct each calendar day by incrementing the day field directly
    return List.generate(
      7,
      (index) => DateTime(sunday.year, sunday.month, sunday.day + index),
    );
  }

  /// Returns the WorkoutType for a given weekday (1=Mon, 7=Sun).
  /// Schedule: Sun=Pull, Mon=Legs, Tue=Rest, Wed=Upper, Thu=Lower, Fri=Rest, Sat=Push.
  static WorkoutType getWorkoutTypeForDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.sunday:
        return WorkoutType.pull;
      case DateTime.monday:
        return WorkoutType.legs;
      case DateTime.tuesday:
        return WorkoutType.rest;
      case DateTime.wednesday:
        return WorkoutType.upper;
      case DateTime.thursday:
        return WorkoutType.lower;
      case DateTime.friday:
        return WorkoutType.rest;
      case DateTime.saturday:
        return WorkoutType.push;
      default:
        return WorkoutType.rest;
    }
  }
}

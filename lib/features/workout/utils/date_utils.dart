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

  /// Returns the Sunday-Saturday week range for a given date.
  static List<DateTime> getWeekDays(DateTime date) {
    // Sunday is 7 in DateTime.weekday (or 0 depending on interpretation, 
    // but Dart's DateTime.weekday uses 1=Mon, 7=Sun).
    // We want Sunday to be the first day.
    int currentWeekday = date.weekday;
    // If it's Sunday (7), we subtract 0 to stay at Sunday.
    // If it's Monday (1), we subtract 1.
    // If it's Saturday (6), we subtract 6.
    int daysToSubtract = currentWeekday % 7;
    
    DateTime sunday = date.subtract(Duration(days: daysToSubtract));
    // Reset to midnight
    sunday = DateTime(sunday.year, sunday.month, sunday.day);

    return List.generate(7, (index) => sunday.add(Duration(days: index)));
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

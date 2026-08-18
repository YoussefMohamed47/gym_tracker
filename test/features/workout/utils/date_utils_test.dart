import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/utils/date_utils.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';

void main() {
  group('WorkoutDateUtils', () {
    test('formatDateKey normalizes to yyyy-MM-dd', () {
      final date = DateTime(2026, 8, 18, 15, 30);
      expect(WorkoutDateUtils.formatDateKey(date), '2026-08-18');
    });

    test('getWeekDays returns Sunday-Saturday range', () {
      // 2026-08-18 is a Tuesday
      final date = DateTime(2026, 8, 18);
      final weekDays = WorkoutDateUtils.getWeekDays(date);

      expect(weekDays.length, 7);
      expect(weekDays[0].weekday, DateTime.sunday);
      expect(WorkoutDateUtils.formatDateKey(weekDays[0]), '2026-08-16'); // Sunday
      expect(WorkoutDateUtils.formatDateKey(weekDays[6]), '2026-08-22'); // Saturday
      expect(weekDays[6].weekday, DateTime.saturday);
    });

    test('getWeekDays handles week boundary (Sunday start)', () {
      final sunday = DateTime(2026, 8, 16);
      final weekDays = WorkoutDateUtils.getWeekDays(sunday);
      expect(WorkoutDateUtils.formatDateKey(weekDays[0]), '2026-08-16');
    });

    test('getWeekDays handles week boundary (Saturday end)', () {
      final saturday = DateTime(2026, 8, 22);
      final weekDays = WorkoutDateUtils.getWeekDays(saturday);
      expect(WorkoutDateUtils.formatDateKey(weekDays[0]), '2026-08-16');
    });

    test('getWorkoutTypeForDay returns correct types', () {
      // Sun=Pull, Mon=Legs, Tue=Rest, Wed=Upper, Thu=Lower, Fri=Rest, Sat=Push.
      expect(WorkoutDateUtils.getWorkoutTypeForDay(DateTime(2026, 8, 16)), WorkoutType.pull);
      expect(WorkoutDateUtils.getWorkoutTypeForDay(DateTime(2026, 8, 17)), WorkoutType.legs);
      expect(WorkoutDateUtils.getWorkoutTypeForDay(DateTime(2026, 8, 18)), WorkoutType.rest);
      expect(WorkoutDateUtils.getWorkoutTypeForDay(DateTime(2026, 8, 19)), WorkoutType.upper);
      expect(WorkoutDateUtils.getWorkoutTypeForDay(DateTime(2026, 8, 20)), WorkoutType.lower);
      expect(WorkoutDateUtils.getWorkoutTypeForDay(DateTime(2026, 8, 21)), WorkoutType.rest);
      expect(WorkoutDateUtils.getWorkoutTypeForDay(DateTime(2026, 8, 22)), WorkoutType.push);
    });
  });
}

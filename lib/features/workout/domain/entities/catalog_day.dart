import 'catalog_exercise.dart';
import 'workout_type.dart';

class CatalogDay {
  final int dayNumber; // 1 to 8
  final String title; // e.g. "Chest & Back", "Rest", etc.
  final WorkoutType workoutType;
  final bool isRestDay;
  final List<CatalogExercise> exercises;

  const CatalogDay({
    required this.dayNumber,
    required this.title,
    required this.workoutType,
    this.isRestDay = false,
    this.exercises = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogDay &&
          runtimeType == other.runtimeType &&
          dayNumber == other.dayNumber &&
          title == other.title &&
          workoutType == other.workoutType &&
          isRestDay == other.isRestDay;

  @override
  int get hashCode =>
      dayNumber.hashCode ^
      title.hashCode ^
      workoutType.hashCode ^
      isRestDay.hashCode;
}

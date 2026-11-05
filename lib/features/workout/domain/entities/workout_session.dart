import '../../../../core/utils/weight_converter.dart';
import 'exercise_log.dart';
import 'workout_type.dart';

class WorkoutSession {
  final String dateKey; // yyyy-MM-dd
  final WorkoutType workoutType;
  final Map<String, ExerciseLog> exerciseLogs;
  final WeightUnit displayUnit;

  const WorkoutSession({
    required this.dateKey,
    required this.workoutType,
    required this.exerciseLogs,
    required this.displayUnit,
  });

  WorkoutSession copyWith({
    Map<String, ExerciseLog>? exerciseLogs,
    WeightUnit? displayUnit,
  }) {
    return WorkoutSession(
      dateKey: dateKey,
      workoutType: workoutType,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      displayUnit: displayUnit ?? this.displayUnit,
    );
  }
}

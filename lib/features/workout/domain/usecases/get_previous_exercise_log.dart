import '../../../../core/error/api_result.dart';
import '../entities/previous_exercise_log.dart';
import '../repositories/workout_repository.dart';

class GetPreviousExerciseLog {
  final WorkoutRepository repository;

  GetPreviousExerciseLog(this.repository);

  /// For each exercise, the newest session before [beforeDateKey] in which
  /// it was done, on any training day. Used for "Last time" and to prefill
  /// weight and reps.
  Future<ApiResult<Map<String, PreviousExerciseLog>>> call(
    List<String> exerciseIds, {
    required String beforeDateKey,
  }) {
    return repository.getLastPerformedExerciseLogs(
      exerciseIds,
      beforeDateKey: beforeDateKey,
    );
  }
}

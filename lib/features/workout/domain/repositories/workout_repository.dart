import '../../../../core/error/api_result.dart';
import '../../../../core/utils/weight_converter.dart';
import '../entities/previous_exercise_log.dart';
import '../entities/workout_session.dart';
import '../entities/workout_type.dart';

abstract class WorkoutRepository {
  Future<WorkoutSession?> getSessionForDate(String dateKey);
  Future<void> saveSession(WorkoutSession session);
  Future<void> deleteSession(String dateKey);
  Future<List<WorkoutSession>> getHistory();

  Future<WeightUnit> getPreferredUnit();
  Future<void> setPreferredUnit(WeightUnit unit);

  /// For each of [exerciseIds], the newest session before [beforeDateKey] in
  /// which that exercise was done (at least one set ticked), on any training
  /// day. IDs never done are left out. Only ticked sets keep their numbers.
  /// An empty [beforeDateKey] searches the whole history.
  Future<ApiResult<Map<String, PreviousExerciseLog>>>
  getLastPerformedExerciseLogs(
    List<String> exerciseIds, {
    required String beforeDateKey,
  });

  /// Gets the type of the last workout that was saved in history.
  Future<WorkoutType?> getLastCompletedWorkoutType();

  /// Gets the most recent workout types in reverse chronological order.
  Future<List<WorkoutType>> getRecentWorkoutTypes({int limit = 5});
}

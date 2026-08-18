import '../../../../core/utils/weight_converter.dart';
import '../entities/exercise_log.dart';
import '../entities/workout_session.dart';

abstract class WorkoutRepository {
  Future<WorkoutSession?> getSessionForDate(String dateKey);
  Future<void> saveSession(WorkoutSession session);
  Future<void> deleteSession(String dateKey);
  Future<List<WorkoutSession>> getHistory();
  
  Future<WeightUnit> getPreferredUnit();
  Future<void> setPreferredUnit(WeightUnit unit);

  /// Gets the most recent performance of an exercise within a specific workout type.
  Future<ExerciseLog?> getPreviousExerciseLog(String workoutType, String exerciseId);
}

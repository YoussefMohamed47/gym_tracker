import '../entities/exercise_log.dart';
import '../repositories/workout_repository.dart';

class GetPreviousExerciseLog {
  final WorkoutRepository repository;

  GetPreviousExerciseLog(this.repository);

  /// Gets the previous log for an exercise in a specific workout type.
  /// This is used for prefilling "Today's Weight".
  Future<ExerciseLog?> call(String workoutType, String exerciseId) async {
    return await repository.getPreviousExerciseLog(workoutType, exerciseId);
  }
}

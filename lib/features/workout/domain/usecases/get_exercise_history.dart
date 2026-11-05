import '../entities/exercise_log.dart';
import '../repositories/workout_repository.dart';

class GetExerciseHistory {
  final WorkoutRepository repository;

  GetExerciseHistory(this.repository);

  Future<List<ExerciseHistoryEntry>> call(
    String workoutTypeName,
    String exerciseId,
  ) async {
    final history = await repository.getHistory();
    final List<ExerciseHistoryEntry> results = [];

    for (final session in history) {
      for (final log in session.exerciseLogs.values) {
        // We match by performed exercise ID
        if (log.performedExerciseId == exerciseId) {
          // If workout type matches, it's a stronger match,
          // but history shows all performances of that exercise.
          // Spec says: "workout type where useful"
          results.add(
            ExerciseHistoryEntry(
              dateKey: session.dateKey,
              workoutTypeName: session.workoutType.name,
              log: log,
            ),
          );
        }
      }
    }

    return results;
  }
}

class ExerciseHistoryEntry {
  final String dateKey;
  final String workoutTypeName;
  final ExerciseLog log;

  ExerciseHistoryEntry({
    required this.dateKey,
    required this.workoutTypeName,
    required this.log,
  });
}

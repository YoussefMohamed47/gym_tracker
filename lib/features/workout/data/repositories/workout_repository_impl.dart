import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../models/workout_session_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource localDataSource;

  WorkoutRepositoryImpl({required this.localDataSource});

  @override
  Future<WorkoutSession?> getSessionForDate(String dateKey) async {
    return await localDataSource.getSessionForDate(dateKey);
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    await localDataSource.saveSession(WorkoutSessionModel.fromEntity(session));
  }

  @override
  Future<void> deleteSession(String dateKey) async {
    await localDataSource.deleteSession(dateKey);
  }

  @override
  Future<List<WorkoutSession>> getHistory() async {
    return await localDataSource.getHistory();
  }

  @override
  Future<WeightUnit> getPreferredUnit() async {
    return await localDataSource.getPreferredUnit();
  }

  @override
  Future<void> setPreferredUnit(WeightUnit unit) async {
    await localDataSource.setPreferredUnit(unit);
  }

  @override
  Future<ExerciseLog?> getPreviousExerciseLog(String workoutType, String exerciseId) async {
    final history = await localDataSource.getHistory();
    
    // Filter by workout type and search for the exercise in logs
    for (final session in history) {
      if (session.workoutType.name == workoutType) {
        // Find if this exercise was performed in this session
        // Note: It could be the performedExerciseId if it was an alternative,
        // but the prefill logic usually looks for the most recent log for that specific exercise ID.
        // The spec says: "Prefills are pulled only from the previous performance within the same workout type."
        
        // We look for any log where performedExerciseId matches our exerciseId
        for (final log in session.exerciseLogs.values) {
          if (log.performedExerciseId == exerciseId && log.isPerformed) {
            return log;
          }
        }
      }
    }
    return null;
  }
}

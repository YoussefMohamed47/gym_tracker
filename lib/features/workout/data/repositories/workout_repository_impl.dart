import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource localDataSource;

  WorkoutRepositoryImpl({required this.localDataSource});

  @override
  Future<WorkoutSession?> getSessionForDate(String dateKey) async {
    final session = await localDataSource.getSessionForDate(dateKey);
    if (session == null) return null;

    // Map legacy IDs to canonical IDs on load to ensure UI consistency
    final Map<String, ExerciseLog> normalizedLogs = {};
    for (var entry in session.exerciseLogs.entries) {
      final normalizedLog = _normalizeLog(entry.value);
      normalizedLogs[normalizedLog.plannedExerciseId] = normalizedLog;
    }

    return session.copyWith(exerciseLogs: normalizedLogs);
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    await localDataSource.saveSession(session);
  }

  @override
  Future<void> deleteSession(String dateKey) async {
    await localDataSource.deleteSession(dateKey);
  }

  @override
  Future<List<WorkoutSession>> getHistory() async {
    final history = await localDataSource.getHistory();
    return history.map((session) {
      final Map<String, ExerciseLog> normalizedLogs = {};
      for (var entry in session.exerciseLogs.entries) {
        final normalizedLog = _normalizeLog(entry.value);
        normalizedLogs[normalizedLog.plannedExerciseId] = normalizedLog;
      }
      return session.copyWith(exerciseLogs: normalizedLogs);
    }).toList();
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
  Future<ExerciseLog?> getPreviousExerciseLog(
    String workoutType,
    String exerciseId,
  ) async {
    final history = await getHistory();
    final canonicalId = _normalizeId(exerciseId);

    // Filter by workout type and search for the exercise in logs
    for (final session in history) {
      if (session.workoutType.name == workoutType) {
        for (final log in session.exerciseLogs.values) {
          final isEffectivelyPerformed =
              log.isPerformed || log.sets.any((s) => s.isPerformed);
          if (_normalizeId(log.performedExerciseId) == canonicalId &&
              isEffectivelyPerformed) {
            return log;
          }
        }
      }
    }
    return null;
  }

  /// Normalizes an ExerciseLog by mapping its IDs to canonical versions.
  ExerciseLog _normalizeLog(ExerciseLog log) {
    return log.copyWith(
      plannedExerciseId: _normalizeId(log.plannedExerciseId),
      performedExerciseId: _normalizeId(log.performedExerciseId),
    );
  }

  /// Map of legacy IDs to canonical IDs.
  static const Map<String, String> _legacyIdMap = {
    'push_lateral_raise': 'push_cable_lateral_raises',
    'push_tricep_pushdown': 'push_triceps_push_down',
    'legs_leg_press': 'legs_seated_leg_press_calve_raises',
    'legs_rdl': 'legs_body_weighted_rdl',
    'legs_calf_raise': 'legs_seated_leg_press_calve_raises',
    'pull_lat_pulldown': 'pull_sa_lat_pull_down',
    'pull_face_pull':
        'pull_cable_rear_delt_fly', // Note: Catalog had Face Pull, source has Rear Delt Fly
    'pull_sa_iso_lateral_lat_row':
        'pull_sa_iso_lateral_lat_row', // Identity remains
  };

  String _normalizeId(String id) {
    return _legacyIdMap[id] ?? id;
  }
}

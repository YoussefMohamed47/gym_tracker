import '../../../../core/error/api_result.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';
import '../../domain/entities/previous_exercise_log.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_type.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_catalog.dart';
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
  Future<ApiResult<Map<String, PreviousExerciseLog>>>
  getLastPerformedExerciseLogs(
    List<String> exerciseIds, {
    required String beforeDateKey,
  }) async {
    try {
      // Newest first, per the data source contract.
      final history = await getHistory();
      final wanted = <String, List<String>>{};
      for (final id in exerciseIds) {
        wanted.putIfAbsent(_historyId(id), () => []).add(id);
      }

      final found = <String, PreviousExerciseLog>{};
      for (final session in history) {
        if (wanted.isEmpty) break;
        if (beforeDateKey.isNotEmpty &&
            session.dateKey.compareTo(beforeDateKey) >= 0) {
          continue;
        }
        for (final log in session.exerciseLogs.values) {
          final isEffectivelyPerformed =
              log.isPerformed || log.sets.any((s) => s.isPerformed);
          if (!isEffectivelyPerformed) continue;
          final ids = wanted.remove(_historyId(log.performedExerciseId));
          if (ids == null) continue;
          final previous = PreviousExerciseLog(
            dateKey: session.dateKey,
            log: _doneSetsOnly(log),
          );
          for (final id in ids) {
            found[id] = previous;
          }
        }
      }
      return ApiSuccess(found);
    } catch (_) {
      return const ApiFailure(CacheFailure('Could not read workout history'));
    }
  }

  String _historyId(String exerciseId) =>
      WorkoutCatalog.sharedExerciseId(_normalizeId(exerciseId));

  /// Keeps set positions but drops the numbers of sets not ticked done, so a
  /// skipped set is never shown or prefilled as "last time".
  ExerciseLog _doneSetsOnly(ExerciseLog log) {
    if (log.sets.every((s) => s.isPerformed)) return log;
    return log.copyWith(
      sets: [
        for (final s in log.sets)
          s.isPerformed ? s : const ExerciseSetLog(isPerformed: false),
      ],
    );
  }

  @override
  Future<WorkoutType?> getLastCompletedWorkoutType() async {
    final recent = await getRecentWorkoutTypes(limit: 1);
    return recent.isNotEmpty ? recent.first : null;
  }

  @override
  Future<List<WorkoutType>> getRecentWorkoutTypes({int limit = 5}) async {
    final history = await getHistory();
    if (history.isEmpty) return [];

    final sortedHistory = List<WorkoutSession>.from(history)
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

    return sortedHistory.take(limit).map((s) => s.workoutType).toList();
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

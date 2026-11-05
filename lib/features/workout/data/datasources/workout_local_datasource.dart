import 'package:hive_ce/hive.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../../../core/storage/hive/models/app_settings_hive_model.dart';
import '../models/workout_session_hive_model.dart';
import '../models/exercise_log_hive_model.dart';
import '../models/exercise_set_log_hive_model.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_type.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';

abstract class WorkoutLocalDataSource {
  Future<WorkoutSession?> getSessionForDate(String dateKey);
  Future<void> saveSession(WorkoutSession session);
  Future<void> deleteSession(String dateKey);
  Future<List<WorkoutSession>> getHistory();

  Future<WeightUnit> getPreferredUnit();
  Future<void> setPreferredUnit(WeightUnit unit);
}

class WorkoutLocalDataSourceImpl implements WorkoutLocalDataSource {
  final Box<WorkoutSessionHiveModel> sessionBox;
  final Box<AppSettingsHiveModel> settingsBox;

  static const String unitPreferenceKey = 'WORKOUT_UNIT_PREFERENCE';

  WorkoutLocalDataSourceImpl({
    required this.sessionBox,
    required this.settingsBox,
  });

  @override
  Future<WorkoutSession?> getSessionForDate(String dateKey) async {
    final model = sessionBox.get(dateKey);
    if (model == null) return null;
    return _fromHiveModel(model);
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    await sessionBox.put(session.dateKey, _toHiveModel(session));
    await sessionBox.flush();
  }

  @override
  Future<void> deleteSession(String dateKey) async {
    await sessionBox.delete(dateKey);
    await sessionBox.flush();
  }

  @override
  Future<List<WorkoutSession>> getHistory() async {
    final sessions = sessionBox.values.map(_fromHiveModel).toList();
    // Sort by dateKey descending (newest first)
    sessions.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return sessions;
  }

  @override
  Future<WeightUnit> getPreferredUnit() async {
    final unitString = settingsBox.get('current')?.weightUnit;
    if (unitString == null) return WeightUnit.kg;
    return WeightUnit.values.firstWhere(
      (e) => e.name == unitString,
      orElse: () => WeightUnit.kg,
    );
  }

  @override
  Future<void> setPreferredUnit(WeightUnit unit) async {
    await settingsBox.put(
      'current',
      AppSettingsHiveModel(weightUnit: unit.name),
    );
  }

  WorkoutSessionHiveModel _toHiveModel(WorkoutSession session) {
    return WorkoutSessionHiveModel(
      dateKey: session.dateKey,
      workoutType: session.workoutType.name,
      displayUnit: session.displayUnit.name,
      exerciseLogs: session.exerciseLogs.values.map((log) {
        final sets = <ExerciseSetLogHiveModel>[];
        for (int i = 0; i < log.sets.length; i++) {
          final s = log.sets[i];
          sets.add(
            ExerciseSetLogHiveModel(
              setIndex: i,
              weightKg: s.weightKg ?? 0.0,
              isPerformed: s.isPerformed,
              actualReps: s.actualReps,
            ),
          );
        }
        return ExerciseLogHiveModel(
          plannedExerciseId: log.plannedExerciseId,
          performedExerciseId: log.performedExerciseId,
          sets: sets,
          weightKg: log.weightKg,
          isPerformed: log.isPerformed,
          imagePath: log.imagePath,
          timestamp: log.timestamp,
          displayUnit: log.displayUnit.name,
        );
      }).toList(),
    );
  }

  WorkoutSession _fromHiveModel(WorkoutSessionHiveModel model) {
    final logs = <String, ExerciseLog>{};
    for (final logModel in model.exerciseLogs) {
      logs[logModel.plannedExerciseId] = ExerciseLog(
        plannedExerciseId: logModel.plannedExerciseId,
        performedExerciseId: logModel.performedExerciseId,
        sets: logModel.sets
            .map(
              (s) => ExerciseSetLog(
                weightKg: s.weightKg,
                actualReps: s.actualReps,
                isPerformed: s.isPerformed,
              ),
            )
            .toList(),
        weightKg: logModel.weightKg,
        isPerformed: logModel.isPerformed,
        imagePath: logModel.imagePath,
        timestamp: logModel.timestamp,
        displayUnit: WeightUnit.values.firstWhere(
          (e) => e.name == logModel.displayUnit,
          orElse: () => WeightUnit.kg,
        ),
      );
    }

    return WorkoutSession(
      dateKey: model.dateKey,
      workoutType: WorkoutType.values.firstWhere(
        (e) => e.name == model.workoutType,
      ),
      displayUnit: WeightUnit.values.firstWhere(
        (e) => e.name == model.displayUnit,
        orElse: () => WeightUnit.kg,
      ),
      exerciseLogs: logs,
    );
  }
}

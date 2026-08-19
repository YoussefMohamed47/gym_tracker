import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../hive/hive_boxes.dart';
import '../hive/models/migration_meta_hive_model.dart';
import '../hive/models/app_settings_hive_model.dart';
import '../../../features/daily_report/data/models/daily_report_hive_model.dart';
import '../../../features/workout/data/models/workout_session_hive_model.dart';
import '../../../features/workout/data/models/exercise_log_hive_model.dart';
import '../../../features/workout/data/models/exercise_set_log_hive_model.dart';
import 'migration_result.dart';
import 'media_migrator.dart';

import '../hive/hive_local_storage.dart';

class LegacyPersistenceMigrator {
  final SharedPreferences prefs;
  final MediaMigrator? mediaMigrator;
  final HiveLocalStorage hiveStorage;

  static const String _reportKey = 'report_history';
  static const String _workoutKey = 'WORKOUT_HISTORY_V1';
  static const String _unitKey = 'WORKOUT_UNIT_PREFERENCE';

  LegacyPersistenceMigrator({
    required this.prefs,
    this.mediaMigrator,
    required this.hiveStorage,
  });

  Future<MigrationResult> migrate() async {
    final metaBox = hiveStorage.getBox<MigrationMetaHiveModel>(
      HiveBoxes.migrationMeta,
    );
    final currentMeta = metaBox.get('meta');

    if (currentMeta?.state == MigrationStatus.completed.index) {
      return const MigrationResult(status: MigrationStatus.completed);
    }

    int successfulCount = 0;
    int failedCount = 0;
    bool hasWarnings = false;

    try {
      // Check if migration is even needed (any legacy key exists)
      final hasLegacyData =
          prefs.containsKey(_reportKey) ||
          prefs.containsKey(_workoutKey) ||
          prefs.containsKey(_unitKey);

      if (!hasLegacyData) {
        await metaBox.put(
          'meta',
          MigrationMetaHiveModel(
            state: MigrationStatus.completed.index,
            lastAttempt: DateTime.now(),
            unresolvedCount: 0,
            version: 1,
          ),
        );
        return const MigrationResult(status: MigrationStatus.completed);
      }

      // 1. Migrate Settings
      final unit = prefs.getString(_unitKey);
      if (unit != null) {
        final settingsBox = hiveStorage.getBox<AppSettingsHiveModel>(
          HiveBoxes.settings,
        );
        if (!settingsBox.containsKey('current')) {
          await settingsBox.put(
            'current',
            AppSettingsHiveModel(weightUnit: unit),
          );
          successfulCount++;
        }
      }

      // 2. Migrate Daily Reports
      final reportsJson = prefs.getString(_reportKey);
      if (reportsJson != null) {
        final List<dynamic> legacyReports = json.decode(reportsJson);
        final reportBox = hiveStorage.getBox<DailyReportHiveModel>(
          HiveBoxes.dailyReports,
        );

        for (final item in legacyReports) {
          try {
            final id = item['id'] as String;
            if (!reportBox.containsKey(id)) {
              final mapped = await _mapDailyReport(item);
              await reportBox.put(id, mapped);
              successfulCount++;
            }
          } catch (e) {
            failedCount++;
            hasWarnings = true;
          }
        }
      }

      // 3. Migrate Workouts
      final workoutsJson = prefs.getString(_workoutKey);
      if (workoutsJson != null) {
        final Map<String, dynamic> legacyWorkouts = json.decode(workoutsJson);
        final workoutBox = hiveStorage.getBox<WorkoutSessionHiveModel>(
          HiveBoxes.workoutSessions,
        );

        for (final entry in legacyWorkouts.entries) {
          try {
            final dateKey = entry.key;
            if (!workoutBox.containsKey(dateKey)) {
              final mapped = await _mapWorkoutSession(dateKey, entry.value);
              await workoutBox.put(dateKey, mapped);
              successfulCount++;
            }
          } catch (e) {
            failedCount++;
            hasWarnings = true;
          }
        }
      }

      // Finalize
      final finalStatus = hasWarnings
          ? MigrationStatus.completedWithWarnings
          : MigrationStatus.completed;

      await metaBox.put(
        'meta',
        MigrationMetaHiveModel(
          state: finalStatus.index,
          lastAttempt: DateTime.now(),
          unresolvedCount: failedCount,
          version: 1,
        ),
      );

      // Cleanup recognized keys only if fully successful (no warnings)
      if (!hasWarnings) {
        await prefs.remove(_reportKey);
        await prefs.remove(_workoutKey);
        await prefs.remove(_unitKey);
      }

      return MigrationResult(
        status: finalStatus,
        successfulCount: successfulCount,
        failedCount: failedCount,
      );
    } catch (e) {
      return MigrationResult(
        status: MigrationStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<DailyReportHiveModel> _mapDailyReport(
    Map<String, dynamic> json,
  ) async {
    String? imagePath = json['imagePath'] as String?;
    if (mediaMigrator != null && imagePath != null) {
      imagePath = await mediaMigrator!.rescueFile(imagePath);
    }

    return DailyReportHiveModel(
      id: json['id'] as String,
      breakfast: json['breakfast'] as String? ?? '',
      lunch: json['lunch'] as String? ?? '',
      snack: json['snack'] as String? ?? '',
      beforeTraining: json['beforeTraining'] as String? ?? '',
      afterTraining: json['afterTraining'] as String? ?? '',
      dinner: json['dinner'] as String? ?? '',
      water: json['water'] as String? ?? '',
      training: json['training'] as String? ?? '',
      cardio: json['cardio'] as String? ?? '',
      supplements: json['supplements'] as String? ?? '',
      sleepTime: json['sleepTime'] as String? ?? '',
      notes: json['notes'] as String?,
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : null,
      imagePath: imagePath,
    );
  }

  Future<WorkoutSessionHiveModel> _mapWorkoutSession(
    String dateKey,
    Map<String, dynamic> json,
  ) async {
    final logsJson = json['exerciseLogs'] as Map<String, dynamic>;
    final logs = <ExerciseLogHiveModel>[];
    for (final e in logsJson.entries) {
      logs.add(await _mapExerciseLog(e.value));
    }

    return WorkoutSessionHiveModel(
      dateKey: dateKey,
      workoutType: json['workoutType'] as String,
      exerciseLogs: logs,
      displayUnit: json['displayUnit'] as String? ?? 'kg',
    );
  }

  Future<ExerciseLogHiveModel> _mapExerciseLog(
    Map<String, dynamic> json,
  ) async {
    List<ExerciseSetLogHiveModel> sets = [];
    if (json.containsKey('sets') && json['sets'] != null) {
      sets = (json['sets'] as List)
          .map(
            (s) => ExerciseSetLogHiveModel(
              setIndex: s['setIndex'] as int,
              weightKg: (s['weightKg'] as num).toDouble(),
              isPerformed: s['isPerformed'] as bool? ?? false,
            ),
          )
          .toList();
    }

    String? imagePath = json['imagePath'] as String?;
    if (mediaMigrator != null && imagePath != null) {
      imagePath = await mediaMigrator!.rescueFile(imagePath);
    }

    return ExerciseLogHiveModel(
      plannedExerciseId: json['plannedExerciseId'] as String,
      performedExerciseId: json['performedExerciseId'] as String,
      sets: sets,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      isPerformed: json['isPerformed'] as bool? ?? false,
      imagePath: imagePath,
      timestamp: DateTime.parse(json['timestamp']),
      displayUnit: json['displayUnit'] as String? ?? 'kg',
    );
  }
}

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/storage/hive/models/app_settings_hive_model.dart';
import 'package:hive_ce/hive.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:gym_tracker_report/features/workout/data/models/workout_session_hive_model.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/core/storage/hive/hive_registrar.dart';
import 'package:gym_tracker_report/core/storage/hive/hive_boxes.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';

void main() {
  late Directory tempDir;
  late WorkoutLocalDataSourceImpl dataSource;
  late Box<WorkoutSessionHiveModel> sessionBox;
  late Box<AppSettingsHiveModel> settingsBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('workout_ds_test');
    Hive.init(tempDir.path);
    try {
      HiveRegistrar.registerAdapters();
    } catch (_) {}

    sessionBox = await Hive.openBox<WorkoutSessionHiveModel>(
      HiveBoxes.workoutSessions,
    );
    settingsBox = await Hive.openBox<AppSettingsHiveModel>(HiveBoxes.settings);
    dataSource = WorkoutLocalDataSourceImpl(
      sessionBox: sessionBox,
      settingsBox: settingsBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('WorkoutLocalDataSourceImpl Tests', () {
    test('Save and retrieve workout session', () async {
      final session = WorkoutSession(
        dateKey: '2026-08-19',
        workoutType: WorkoutType.push,
        displayUnit: WeightUnit.kg,
        exerciseLogs: const {},
      );

      await dataSource.saveSession(session);
      final retrieved = await dataSource.getSessionForDate('2026-08-19');

      expect(retrieved?.dateKey, '2026-08-19');
      expect(retrieved?.workoutType, WorkoutType.push);
    });

    test('Get history is sorted descending', () async {
      await dataSource.saveSession(
        WorkoutSession(
          dateKey: '2026-08-18',
          workoutType: WorkoutType.push,
          displayUnit: WeightUnit.kg,
          exerciseLogs: const {},
        ),
      );
      await dataSource.saveSession(
        WorkoutSession(
          dateKey: '2026-08-20',
          workoutType: WorkoutType.push,
          displayUnit: WeightUnit.kg,
          exerciseLogs: const {},
        ),
      );

      final history = await dataSource.getHistory();
      expect(history.first.dateKey, '2026-08-20');
      expect(history.last.dateKey, '2026-08-18');
    });
  });
}

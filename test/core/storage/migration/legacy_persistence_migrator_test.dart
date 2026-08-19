import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/storage/hive/hive_local_storage.dart';
import 'package:gym_tracker_report/core/storage/hive/models/app_settings_hive_model.dart';
import 'package:gym_tracker_report/core/storage/hive/models/migration_meta_hive_model.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_tracker_report/core/storage/migration/legacy_persistence_migrator.dart';
import 'package:gym_tracker_report/core/storage/migration/migration_result.dart';
import 'package:gym_tracker_report/core/storage/hive/hive_registrar.dart';
import 'package:gym_tracker_report/core/storage/hive/hive_boxes.dart';
import 'package:gym_tracker_report/features/workout/data/models/workout_session_hive_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late Directory tempDir;
  late MockSharedPreferences mockPrefs;
  late LegacyPersistenceMigrator migrator;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('migration_test');
    Hive.init(tempDir.path);
    try {
      HiveRegistrar.registerAdapters();
    } catch (_) {}

    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.containsKey(any())).thenReturn(false);
    
    // Open required boxes
    await Hive.openBox<MigrationMetaHiveModel>(HiveBoxes.migrationMeta);
    await Hive.openBox<AppSettingsHiveModel>(HiveBoxes.settings);
    await Hive.openBox<WorkoutSessionHiveModel>(HiveBoxes.workoutSessions);
    
    migrator = LegacyPersistenceMigrator(
      prefs: mockPrefs,
      hiveStorage: HiveLocalStorage(),
    );
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LegacyPersistenceMigrator V3 Compatibility Tests', () {
    test('Migrate V1 SharedPreferences (Single-weight) to V3 Hive', () async {
      final legacyWorkouts = {
        '2026-08-01': {
          'workoutType': 'pull',
          'exerciseLogs': {
            'pull_t_bar_row': {
              'plannedExerciseId': 'pull_t_bar_row',
              'performedExerciseId': 'pull_t_bar_row',
              'weightKg': 50.0,
              'isPerformed': true,
              'timestamp': '2026-08-01T10:00:00.000',
            },
          },
        },
      };

      when(
        () => mockPrefs.getString('WORKOUT_HISTORY_V1'),
      ).thenReturn(json.encode(legacyWorkouts));
      when(() => mockPrefs.containsKey('WORKOUT_HISTORY_V1')).thenReturn(true);
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

      final result = await migrator.migrate();

      expect(result.status, MigrationStatus.completed);
      final box = await Hive.openBox<WorkoutSessionHiveModel>(
        HiveBoxes.workoutSessions,
      );
      final log = box.get('2026-08-01')?.exerciseLogs.first;

      expect(log?.weightKg, 50.0);
      expect(log?.sets, isEmpty); // V1 has no sets
    });

    test(
      'Migrate V2 SharedPreferences (Per-set, No reps) to V3 Hive',
      () async {
        final legacyWorkouts = {
          '2026-08-10': {
            'workoutType': 'push',
            'exerciseLogs': {
              'push_bench': {
                'plannedExerciseId': 'push_bench',
                'performedExerciseId': 'push_bench',
                'sets': [
                  {'setIndex': 0, 'weightKg': 60.0, 'isPerformed': true},
                  {'setIndex': 1, 'weightKg': 60.0, 'isPerformed': true},
                ],
                'timestamp': '2026-08-10T10:00:00.000',
              },
            },
          },
        };

        when(
          () => mockPrefs.getString('WORKOUT_HISTORY_V1'),
        ).thenReturn(json.encode(legacyWorkouts));
        when(
          () => mockPrefs.containsKey('WORKOUT_HISTORY_V1'),
        ).thenReturn(true);
        when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

        final result = await migrator.migrate();

        expect(result.status, MigrationStatus.completed);
        final box = await Hive.openBox<WorkoutSessionHiveModel>(
          HiveBoxes.workoutSessions,
        );
        final log = box.get('2026-08-10')?.exerciseLogs.first;

        expect(log?.sets.length, 2);
        expect(log?.sets[0].weightKg, 60.0);
        expect(log?.sets[0].actualReps, isNull); // Reps should be null
      },
    );
  });
}

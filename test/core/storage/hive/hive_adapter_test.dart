import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:gym_tracker_report/core/storage/hive/models/app_settings_hive_model.dart';
import 'package:gym_tracker_report/features/daily_report/data/models/daily_report_hive_model.dart';
import 'package:gym_tracker_report/features/workout/data/models/workout_session_hive_model.dart';
import 'package:gym_tracker_report/features/workout/data/models/exercise_log_hive_model.dart';
import 'package:gym_tracker_report/features/workout/data/models/exercise_set_log_hive_model.dart';
import 'package:gym_tracker_report/core/storage/hive/hive_registrar.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    // Register only if not registered to avoid errors in repeated setup
    try {
      HiveRegistrar.registerAdapters();
    } catch (_) {
      // Ignore if already registered
    }
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Hive Adapter Round-trip Tests', () {
    test('DailyReportHiveModel round-trip', () async {
      final box = await Hive.openBox<DailyReportHiveModel>('test_reports');
      final report = DailyReportHiveModel(
        id: '123',
        breakfast: 'Oats',
        lunch: 'Chicken',
        snack: 'Nuts',
        beforeTraining: 'Pre',
        afterTraining: 'Post',
        dinner: 'Fish',
        water: '2L',
        training: 'Heavy',
        cardio: '20min',
        supplements: 'Creatine',
        sleepTime: '8h',
        notes: 'Good day',
        dateTime: DateTime(2026, 8, 19),
        imagePath: 'path/to/image.png',
      );

      await box.put(report.id, report);
      final retrieved = box.get(report.id);

      expect(retrieved?.id, report.id);
      expect(retrieved?.breakfast, report.breakfast);
      expect(retrieved?.imagePath, report.imagePath);
    });

    test('WorkoutSessionHiveModel round-trip', () async {
      final box = await Hive.openBox<WorkoutSessionHiveModel>('test_workouts');
      final setLog = ExerciseSetLogHiveModel(
        setIndex: 1,
        weightKg: 100,
        isPerformed: true,
      );
      final exerciseLog = ExerciseLogHiveModel(
        plannedExerciseId: 'ex1',
        performedExerciseId: 'ex1',
        sets: [setLog],
        isPerformed: true,
        timestamp: DateTime.now(),
        displayUnit: 'kg',
      );
      final session = WorkoutSessionHiveModel(
        dateKey: '2026-08-19',
        workoutType: 'push',
        exerciseLogs: [exerciseLog],
        displayUnit: 'kg',
      );

      await box.put(session.dateKey, session);
      final retrieved = box.get(session.dateKey);

      expect(retrieved?.dateKey, session.dateKey);
      expect(retrieved?.exerciseLogs.first.plannedExerciseId, 'ex1');
      expect(retrieved?.exerciseLogs.first.sets.first.weightKg, 100);
    });

    test('AppSettingsHiveModel round-trip', () async {
      final box = await Hive.openBox<AppSettingsHiveModel>('test_settings');
      final settings = AppSettingsHiveModel(weightUnit: 'lb');

      await box.put('current', settings);
      final retrieved = box.get('current');

      expect(retrieved?.weightUnit, 'lb');
    });
  });
}

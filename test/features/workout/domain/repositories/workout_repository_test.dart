import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/data/models/workout_session_model.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';

class MockWorkoutLocalDataSource extends Mock implements WorkoutLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(WorkoutSessionModel(
      dateKey: '',
      workoutType: WorkoutType.rest,
      exerciseLogs: {},
      displayUnit: WeightUnit.kg,
    ));
  });

  late WorkoutRepositoryImpl repository;
  late MockWorkoutLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockWorkoutLocalDataSource();
    repository = WorkoutRepositoryImpl(localDataSource: mockDataSource);
  });

  final tExerciseLog = ExerciseLog(
    plannedExerciseId: 'ex1',
    performedExerciseId: 'ex1',
    weightKg: 100.0,
    isPerformed: true,
    timestamp: DateTime(2026, 8, 18),
  );

  final tSession = WorkoutSession(
    dateKey: '2026-08-18',
    workoutType: WorkoutType.push,
    exerciseLogs: {'ex1': tExerciseLog},
    displayUnit: WeightUnit.kg,
  );

  group('saveSession', () {
    test('should call localDataSource.saveSession', () async {
      when(() => mockDataSource.saveSession(any())).thenAnswer((_) async => {});

      await repository.saveSession(tSession);

      verify(() => mockDataSource.saveSession(any())).called(1);
    });
  });

  group('getPreviousExerciseLog', () {
    test('should return the most recent log for the same workout type and exercise', () async {
      final session1 = WorkoutSessionModel(
        dateKey: '2026-08-11',
        workoutType: WorkoutType.push,
        exerciseLogs: {
          'ex1': ExerciseLog(
            plannedExerciseId: 'ex1',
            performedExerciseId: 'ex1',
            weightKg: 90.0,
            isPerformed: true,
            timestamp: DateTime(2026, 8, 11),
          )
        },
        displayUnit: WeightUnit.kg,
      );
      final session2 = WorkoutSessionModel(
        dateKey: '2026-08-04',
        workoutType: WorkoutType.push,
        exerciseLogs: {
          'ex1': ExerciseLog(
            plannedExerciseId: 'ex1',
            performedExerciseId: 'ex1',
            weightKg: 80.0,
            isPerformed: true,
            timestamp: DateTime(2026, 8, 4),
          )
        },
        displayUnit: WeightUnit.kg,
      );

      when(() => mockDataSource.getHistory()).thenAnswer((_) async => [session1, session2]);

      final result = await repository.getPreviousExerciseLog('push', 'ex1');

      expect(result?.weightKg, 90.0);
      verify(() => mockDataSource.getHistory()).called(1);
    });

    test('should return null if no previous log found for the workout type', () async {
      final sessionOther = WorkoutSessionModel(
        dateKey: '2026-08-11',
        workoutType: WorkoutType.pull,
        exerciseLogs: {
          'ex1': ExerciseLog(
            plannedExerciseId: 'ex1',
            performedExerciseId: 'ex1',
            weightKg: 90.0,
            isPerformed: true,
            timestamp: DateTime(2026, 8, 11),
          )
        },
        displayUnit: WeightUnit.kg,
      );

      when(() => mockDataSource.getHistory()).thenAnswer((_) async => [sessionOther]);

      final result = await repository.getPreviousExerciseLog('push', 'ex1');

      expect(result, null);
    });
  });
}

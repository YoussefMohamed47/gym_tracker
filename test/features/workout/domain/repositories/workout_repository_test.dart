import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/data/models/workout_session_model.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';

class MockWorkoutLocalDataSource extends Mock
    implements WorkoutLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      WorkoutSessionModel(
        dateKey: '',
        workoutType: WorkoutType.rest,
        exerciseLogs: {},
        displayUnit: WeightUnit.kg,
      ),
    );
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
    sets: const [
      ExerciseSetLog(weightKg: 50, isPerformed: true),
      ExerciseSetLog(weightKg: 55, isPerformed: true),
    ],
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
    test(
      'should return the most recent per-set log for the same workout type and exercise',
      () async {
        final session1 = WorkoutSessionModel(
          dateKey: '2026-08-11',
          workoutType: WorkoutType.push,
          exerciseLogs: {
            'ex1': ExerciseLog(
              plannedExerciseId: 'ex1',
              performedExerciseId: 'ex1',
              sets: const [
                ExerciseSetLog(weightKg: 60, isPerformed: true),
                ExerciseSetLog(weightKg: 65, isPerformed: true),
              ],
              timestamp: DateTime(2026, 8, 11),
            ),
          },
          displayUnit: WeightUnit.kg,
        );

        when(
          () => mockDataSource.getHistory(),
        ).thenAnswer((_) async => [session1]);

        final result = await repository.getPreviousExerciseLog('push', 'ex1');

        expect(result?.sets.length, 2);
        expect(result?.sets[0].weightKg, 60.0);
        expect(result?.sets[1].weightKg, 65.0);
      },
    );

    test(
      'should return legacy log if that is the most recent performed entry',
      () async {
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
            ),
          },
          displayUnit: WeightUnit.kg,
        );

        when(
          () => mockDataSource.getHistory(),
        ).thenAnswer((_) async => [session1]);

        final result = await repository.getPreviousExerciseLog('push', 'ex1');

        expect(result?.weightKg, 90.0);
        expect(result?.sets, isEmpty);
      },
    );
  });
}

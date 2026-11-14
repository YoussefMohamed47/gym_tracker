import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/previous_exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/data/models/workout_session_model.dart';
import 'package:gym_tracker_report/core/error/api_result.dart';
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

  group('getLastPerformedExerciseLogs', () {
    WorkoutSessionModel session(
      String dateKey,
      WorkoutType type,
      String exerciseId, {
      double weightKg = 40,
      bool isPerformed = true,
    }) {
      return WorkoutSessionModel(
        dateKey: dateKey,
        workoutType: type,
        exerciseLogs: {
          exerciseId: ExerciseLog(
            plannedExerciseId: exerciseId,
            performedExerciseId: exerciseId,
            sets: [
              ExerciseSetLog(
                weightKg: weightKg,
                actualReps: 10,
                isPerformed: isPerformed,
              ),
            ],
            timestamp: DateTime(2026, 8, 1),
          ),
        },
        displayUnit: WeightUnit.kg,
      );
    }

    /// History as the data source returns it: newest first.
    void givenHistory(List<WorkoutSessionModel> sessions) {
      when(() => mockDataSource.getHistory()).thenAnswer((_) async => sessions);
    }

    Future<PreviousExerciseLog?> lookup(String exerciseId) async {
      final result = await repository.getLastPerformedExerciseLogs([
        exerciseId,
      ], beforeDateKey: '2026-08-20');
      return switch (result) {
        ApiSuccess(:final data) => data[exerciseId],
        ApiFailure() => fail('unexpected failure'),
      };
    }

    test('returns the per-set log and its date', () async {
      givenHistory([
        WorkoutSessionModel(
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
        ),
      ]);

      final result = await lookup('ex1');

      expect(result?.dateKey, '2026-08-11');
      expect(result?.log.sets.map((s) => s.weightKg), [60.0, 65.0]);
    });

    test("finds the same exercise logged under another day's ID", () async {
      // "Rear Delt Machine Fly" is on Shoulder & Arms and on Full Body.
      givenHistory([
        session(
          '2026-08-10',
          WorkoutType.fullBody,
          'c_rear_delt_machine_fly_fb',
          weightKg: 30,
        ),
      ]);

      final result = await lookup('c_rear_delt_machine_fly');

      expect(result?.dateKey, '2026-08-10');
      expect(result?.log.sets.first.weightKg, 30.0);
    });

    test('returns the newest session whichever training day it was', () async {
      givenHistory([
        session(
          '2026-08-10',
          WorkoutType.fullBody,
          'c_rear_delt_machine_fly_fb',
          weightKg: 30,
        ),
        session(
          '2026-08-01',
          WorkoutType.shoulderAndArms,
          'c_rear_delt_machine_fly',
          weightKg: 25,
        ),
      ]);

      final result = await lookup('c_rear_delt_machine_fly');

      expect(result?.dateKey, '2026-08-10');
    });

    test('ignores sessions on or after the date being opened', () async {
      givenHistory([
        session('2026-08-25', WorkoutType.push, 'ex1', weightKg: 99),
        session('2026-08-20', WorkoutType.push, 'ex1', weightKg: 99),
        session('2026-08-11', WorkoutType.push, 'ex1', weightKg: 60),
      ]);

      final result = await lookup('ex1');

      expect(result?.dateKey, '2026-08-11');
    });

    test('skips sessions where no set was ticked as done', () async {
      givenHistory([
        session('2026-08-15', WorkoutType.push, 'ex1', isPerformed: false),
        session('2026-08-11', WorkoutType.push, 'ex1'),
      ]);

      final result = await lookup('ex1');

      expect(result?.dateKey, '2026-08-11');
    });

    test('drops the numbers of sets not ticked as done', () async {
      givenHistory([
        WorkoutSessionModel(
          dateKey: '2026-08-11',
          workoutType: WorkoutType.push,
          exerciseLogs: {
            'ex1': ExerciseLog(
              plannedExerciseId: 'ex1',
              performedExerciseId: 'ex1',
              sets: const [
                ExerciseSetLog(weightKg: 40, actualReps: 10, isPerformed: true),
                ExerciseSetLog(weightKg: 50, actualReps: 8),
              ],
              timestamp: DateTime(2026, 8, 11),
            ),
          },
          displayUnit: WeightUnit.kg,
        ),
      ]);

      final result = await lookup('ex1');

      expect(result?.log.sets, const [
        ExerciseSetLog(weightKg: 40, actualReps: 10, isPerformed: true),
        ExerciseSetLog(),
      ]);
    });

    test('does not merge different exercises', () async {
      givenHistory([session('2026-08-11', WorkoutType.push, 'unknown_a')]);

      final result = await lookup('unknown_b');

      expect(result, isNull);
    });

    test('looks up several exercises with one history read', () async {
      givenHistory([
        session('2026-08-11', WorkoutType.push, 'ex1'),
        session('2026-08-10', WorkoutType.pull, 'ex2'),
      ]);

      final result = await repository.getLastPerformedExerciseLogs([
        'ex1',
        'ex2',
        'ex3',
      ], beforeDateKey: '2026-08-20');

      final data =
          (result as ApiSuccess<Map<String, PreviousExerciseLog>>).data;
      expect(data.keys, unorderedEquals(['ex1', 'ex2']));
      verify(() => mockDataSource.getHistory()).called(1);
    });

    test('returns a cache failure when history cannot be read', () async {
      when(() => mockDataSource.getHistory()).thenThrow(Exception('disk'));

      final result = await repository.getLastPerformedExerciseLogs([
        'ex1',
      ], beforeDateKey: '2026-08-20');

      expect(
        (result as ApiFailure<Map<String, PreviousExerciseLog>>).failure,
        isA<CacheFailure>(),
      );
    });

    test('returns a legacy whole-exercise log marked performed', () async {
      givenHistory([
        WorkoutSessionModel(
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
        ),
      ]);

      final result = await lookup('ex1');

      expect(result?.log.weightKg, 90.0);
      expect(result?.log.sets, isEmpty);
    });
  });
}

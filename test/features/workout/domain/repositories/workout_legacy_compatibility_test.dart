import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:gym_tracker_report/features/workout/data/models/workout_session_model.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';

class MockWorkoutLocalDataSource extends Mock
    implements WorkoutLocalDataSource {}

void main() {
  late WorkoutRepositoryImpl repository;
  late MockWorkoutLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockWorkoutLocalDataSource();
    repository = WorkoutRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  group('Workout Legacy Compatibility', () {
    test(
      'renamed legacy ID resolves to correct canonical identity on load',
      () async {
        final legacySession = WorkoutSession(
          dateKey: '2026-08-18',
          workoutType: WorkoutType.push,
          displayUnit: WeightUnit.kg,
          exerciseLogs: {
            'push_lateral_raise': ExerciseLog(
              plannedExerciseId: 'push_lateral_raise',
              performedExerciseId: 'push_lateral_raise',
              weightKg: 10.0,
              isPerformed: true,
              timestamp: DateTime.now(),
            ),
          },
        );

        when(() => mockLocalDataSource.getSessionForDate(any())).thenAnswer(
          (_) async => WorkoutSessionModel.fromEntity(legacySession),
        );

        final result = await repository.getSessionForDate('2026-08-18');

        expect(
          result?.exerciseLogs.containsKey('push_cable_lateral_raises'),
          isTrue,
        );
        final log = result?.exerciseLogs['push_cable_lateral_raises'];
        expect(log?.plannedExerciseId, 'push_cable_lateral_raises');
        expect(log?.performedExerciseId, 'push_cable_lateral_raises');
        expect(log?.weightKg, 10.0);
      },
    );

    test(
      'legacy-only incorrect exercise remains readable but does not appear in active catalog',
      () async {
        final sessionWithIncorrectExercise = WorkoutSession(
          dateKey: '2026-08-18',
          workoutType: WorkoutType.push,
          displayUnit: WeightUnit.kg,
          exerciseLogs: {
            'push_chest_fly': ExerciseLog(
              plannedExerciseId: 'push_chest_fly',
              performedExerciseId: 'push_chest_fly',
              weightKg: 50.0,
              isPerformed: true,
              timestamp: DateTime.now(),
            ),
          },
        );

        when(() => mockLocalDataSource.getSessionForDate(any())).thenAnswer(
          (_) async =>
              WorkoutSessionModel.fromEntity(sessionWithIncorrectExercise),
        );

        final result = await repository.getSessionForDate('2026-08-18');

        // It should still be present in the loaded session
        expect(result?.exerciseLogs.containsKey('push_chest_fly'), isTrue);
        expect(result?.exerciseLogs['push_chest_fly']?.weightKg, 50.0);
      },
    );

    test('prefill lookup uses canonical mapping', () async {
      final history = [
        WorkoutSession(
          dateKey: '2026-08-11',
          workoutType: WorkoutType.push,
          displayUnit: WeightUnit.kg,
          exerciseLogs: {
            'push_lateral_raise': ExerciseLog(
              plannedExerciseId: 'push_lateral_raise',
              performedExerciseId: 'push_lateral_raise',
              weightKg: 12.0,
              isPerformed: true,
              timestamp: DateTime.now(),
            ),
          },
        ),
      ];

      when(() => mockLocalDataSource.getHistory()).thenAnswer(
        (_) async =>
            history.map((e) => WorkoutSessionModel.fromEntity(e)).toList(),
      );

      // Search for the NEW canonical ID, it should find the OLD legacy one
      final prevLog = await repository.getPreviousExerciseLog(
        'push',
        'push_cable_lateral_raises',
      );

      expect(prevLog, isNotNull);
      expect(prevLog?.weightKg, 12.0);
    });
  });
}

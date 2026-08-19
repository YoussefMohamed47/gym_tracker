import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/domain/repositories/workout_repository.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_cubit.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_state.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class FakeWorkoutSession extends Fake implements WorkoutSession {}

void main() {
  late WorkoutCubit cubit;
  late MockWorkoutRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeWorkoutSession());
  });

  setUp(() {
    mockRepository = MockWorkoutRepository();
    cubit = WorkoutCubit(repository: mockRepository);
  });

  group('WorkoutCubit - Partial Completion', () {
    test('should identify unperformed exercises correctly', () async {
      final logs = {
        'ex1': ExerciseLog(
          plannedExerciseId: 'ex1',
          performedExerciseId: 'ex1',
          sets: const [
            ExerciseSetLog(weightKg: 50, isPerformed: true),
            ExerciseSetLog(weightKg: null, isPerformed: false),
          ],
          timestamp: DateTime.now(),
        ),
        'ex2': ExerciseLog(
          plannedExerciseId: 'ex2',
          performedExerciseId: 'ex2',
          sets: const [ExerciseSetLog(weightKg: null, isPerformed: false)],
          timestamp: DateTime.now(),
        ),
      };

      cubit.emit(
        cubit.state.copyWith(
          status: WorkoutStatus.success,
          exerciseLogs: logs,
          dateKey: '2026-08-19',
          workoutType: WorkoutType.push,
        ),
      );

      when(() => mockRepository.saveSession(any())).thenAnswer((_) async => {});

      await cubit.saveWorkout();

      expect(cubit.state.status, WorkoutStatus.failure);
      expect(cubit.state.errorMessage, contains('REVIEW_REQUIRED:1'));
    });

    test(
      'should save successfully when at least one set is performed',
      () async {
        final logs = {
          'ex1': ExerciseLog(
            plannedExerciseId: 'ex1',
            performedExerciseId: 'ex1',
            sets: const [ExerciseSetLog(weightKg: 50, isPerformed: true)],
            timestamp: DateTime.now(),
          ),
        };

        cubit.emit(
          cubit.state.copyWith(
            status: WorkoutStatus.success,
            exerciseLogs: logs,
            dateKey: '2026-08-19',
            workoutType: WorkoutType.push,
          ),
        );

        when(
          () => mockRepository.saveSession(any()),
        ).thenAnswer((_) async => {});

        await cubit.saveWorkout();

        expect(cubit.state.status, WorkoutStatus.saved);
        verify(() => mockRepository.saveSession(any())).called(1);
      },
    );
  });
}

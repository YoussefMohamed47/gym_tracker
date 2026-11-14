import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/error/api_result.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/domain/repositories/workout_repository.dart';
import 'package:gym_tracker_report/features/workout/domain/usecases/get_previous_exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/usecases/save_workout_session.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_cubit.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockWorkoutRepository extends Mock implements WorkoutRepository {}

class _FakeWorkoutSession extends Fake implements WorkoutSession {}

/// Lets zero-delay timers and the save they start finish, in order.
Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeWorkoutSession()));

  late _MockWorkoutRepository repository;

  WorkoutCubit makeCubit({Duration? delay = Duration.zero}) {
    final cubit = WorkoutCubit(
      repository: repository,
      getPreviousExerciseLog: GetPreviousExerciseLog(repository),
      saveWorkoutSession: SaveWorkoutSession(repository),
      autoSaveDelay: delay,
    );
    cubit.emit(
      cubit.state.copyWith(
        status: WorkoutStatus.success,
        dateKey: '2026-11-14',
        workoutType: WorkoutType.push,
        exerciseLogs: {
          'ex1': ExerciseLog(
            plannedExerciseId: 'ex1',
            performedExerciseId: 'ex1',
            sets: const [ExerciseSetLog(), ExerciseSetLog()],
            timestamp: DateTime(2026, 11, 14),
          ),
        },
      ),
    );
    return cubit;
  }

  setUp(() {
    repository = _MockWorkoutRepository();
    when(
      () => repository.getLastPerformedExerciseLogs(
        any(),
        beforeDateKey: any(named: 'beforeDateKey'),
      ),
    ).thenAnswer((_) async => const ApiSuccess({}));
    when(() => repository.saveSession(any())).thenAnswer((_) async {});
    when(
      () => repository.getSessionForDate(any()),
    ).thenAnswer((_) async => null);
  });

  test('ticking a set saves the day by itself', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    await cubit.toggleSetPerformed('ex1', 0);
    await _settle();

    final saved =
        verify(() => repository.saveSession(captureAny())).captured.single
            as WorkoutSession;
    expect(saved.dateKey, '2026-11-14');
    expect(saved.exerciseLogs['ex1']!.sets.first.isPerformed, isTrue);
    // Went through SaveWorkoutSession, which checks the old session for
    // photos to clean up before writing.
    verify(() => repository.getSessionForDate('2026-11-14')).called(1);
  });

  test('typing on a day with nothing ticked does not save it', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    cubit.updateSetReps('ex1', 0, 10);
    await _settle();

    verifyNever(() => repository.saveSession(any()));
  });

  test('quick edits in a row are saved once', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    await cubit.toggleSetPerformed('ex1', 0);
    cubit.updateSetReps('ex1', 0, 10);
    cubit.updateSetReps('ex1', 0, 11);
    await _settle();

    verify(() => repository.saveSession(any())).called(1);
  });

  test('once saved, unticking everything is saved too', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    await cubit.toggleSetPerformed('ex1', 0);
    await _settle();
    expect(cubit.state.isEditMode, isTrue);

    await cubit.toggleSetPerformed('ex1', 0);
    await _settle();

    final last =
        verify(() => repository.saveSession(captureAny())).captured.last
            as WorkoutSession;
    expect(last.exerciseLogs['ex1']!.sets.any((s) => s.isPerformed), isFalse);
  });

  test('a failed save is shown, not swallowed', () async {
    when(() => repository.saveSession(any())).thenThrow(Exception('disk'));
    final cubit = makeCubit();
    addTearDown(cubit.close);

    await cubit.toggleSetPerformed('ex1', 0);
    await _settle();

    expect(cubit.state.status, WorkoutStatus.failure);
    expect(cubit.state.errorMessage, contains("Couldn't save"));
  });

  test('switching day saves the edit made just before it', () async {
    when(() => repository.getSessionForDate(any())).thenAnswer((_) async {
      return null;
    });
    when(() => repository.getHistory()).thenAnswer((_) async => []);
    when(
      () => repository.getPreferredUnit(),
    ).thenAnswer((_) async => WeightUnit.kg);
    final cubit = makeCubit(delay: const Duration(hours: 1));
    addTearDown(cubit.close);

    await cubit.toggleSetPerformed('ex1', 0);
    await cubit.loadDate(DateTime(2026, 11, 15));

    final saved =
        verify(() => repository.saveSession(captureAny())).captured.single
            as WorkoutSession;
    expect(saved.dateKey, '2026-11-14');
    expect(saved.exerciseLogs['ex1']!.sets.first.isPerformed, isTrue);
  });

  test('closing saves an edit that was still waiting', () async {
    final cubit = makeCubit(delay: const Duration(hours: 1));

    await cubit.toggleSetPerformed('ex1', 0);
    verifyNever(() => repository.saveSession(any()));

    await cubit.close();

    verify(() => repository.saveSession(any())).called(1);
  });
}

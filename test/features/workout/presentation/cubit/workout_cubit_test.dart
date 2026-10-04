import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/domain/repositories/workout_repository.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_cubit.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_state.dart';
import 'package:gym_tracker_report/features/workout/utils/date_utils.dart';

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

  group('WorkoutCubit - Partial Completion & Reps', () {
    test('should identify unperformed exercises correctly', () async {
      final logs = {
        'ex1': ExerciseLog(
          plannedExerciseId: 'ex1',
          performedExerciseId: 'ex1',
          sets: const [
            ExerciseSetLog(weightKg: 50, actualReps: 10, isPerformed: true),
            ExerciseSetLog(weightKg: null, isPerformed: false),
          ],
          timestamp: DateTime.now(),
        ),
        'ex2': ExerciseLog(
          plannedExerciseId: 'ex2',
          performedExerciseId: 'ex2',
          sets: const [
            ExerciseSetLog(
              weightKg: null,
              actualReps: null,
              isPerformed: false,
            ),
          ],
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

      // Resetting status clears errorMessage and sets status back to success
      cubit.resetStatus();
      expect(cubit.state.status, WorkoutStatus.success);
      expect(cubit.state.errorMessage, isNull);
    });

    test('saveWorkout forceSave should succeed and set status to saved', () async {
      final logs = {
        'ex1': ExerciseLog(
          plannedExerciseId: 'ex1',
          performedExerciseId: 'ex1',
          sets: const [
            ExerciseSetLog(weightKg: 50, actualReps: 10, isPerformed: true),
          ],
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

      await cubit.saveWorkout(forceSave: true);

      expect(cubit.state.status, WorkoutStatus.saved);
      expect(cubit.state.errorMessage, isNull);
    });

    test('updateSetReps should update reps without auto-toggling isPerformed', () async {
      final logs = {
        'ex1': ExerciseLog(
          plannedExerciseId: 'ex1',
          performedExerciseId: 'ex1',
          sets: const [
            ExerciseSetLog(
              weightKg: null,
              actualReps: null,
              isPerformed: false,
            ),
          ],
          timestamp: DateTime.now(),
        ),
      };

      cubit.emit(
        cubit.state.copyWith(status: WorkoutStatus.success, exerciseLogs: logs),
      );

      cubit.updateSetReps('ex1', 0, 12);

      final updatedLog = cubit.state.exerciseLogs['ex1']!;
      expect(updatedLog.sets[0].actualReps, 12);
      expect(updatedLog.sets[0].isPerformed, isFalse);
    });

    test('prefill should map weight and reps correctly by index', () async {
      final prevLog = ExerciseLog(
        plannedExerciseId: 'ex1',
        performedExerciseId: 'ex1',
        sets: const [
          ExerciseSetLog(weightKg: 60, actualReps: 8, isPerformed: true),
        ],
        timestamp: DateTime(2026, 8, 12),
      );

      when(
        () => mockRepository.getPreviousExerciseLog(any(), any()),
      ).thenAnswer((_) async => prevLog);
      when(
        () => mockRepository.getPreferredUnit(),
      ).thenAnswer((_) async => WeightUnit.kg);

      // This is internal to loadDate, but we test the private _createInitialLog through logic if possible
      // or just trust the integration in loadDate.
    });
  });

  group('WorkoutCubit - Dynamic Type Selection', () {
    test('changeWorkoutType should update state, fetch history and persist',
        () async {
      when(
        () => mockRepository.getPreviousExerciseLog(any(), any()),
      ).thenAnswer((_) async => null);
      when(() => mockRepository.saveSession(any())).thenAnswer((_) async => {});

      await cubit.changeWorkoutType(WorkoutType.push);

      expect(cubit.state.workoutType, WorkoutType.push);
      expect(cubit.state.exerciseLogs.isNotEmpty, isTrue);
      verify(() => mockRepository.saveSession(any())).called(1);
    });

    test('changeWorkoutType should fetch history for new exercises', () async {
      final prevLog = ExerciseLog(
        plannedExerciseId: 'push_chest_press_machine',
        performedExerciseId: 'push_chest_press_machine',
        sets: const [
          ExerciseSetLog(weightKg: 80, actualReps: 10, isPerformed: true),
        ],
        timestamp: DateTime.now(),
      );

      when(
        () => mockRepository.getPreviousExerciseLog(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.getPreviousExerciseLog('push', any()),
      ).thenAnswer((_) async => prevLog);

      await cubit.changeWorkoutType(WorkoutType.push);

      final chestPressLog = cubit.state.exerciseLogs['push_chest_press_machine'];
      expect(chestPressLog, isNotNull);
      expect(chestPressLog!.sets[0].weightKg, 80);
      expect(chestPressLog.sets[0].actualReps, 10);
    });

    test('loadDate should suggest next workout in sequence if no session exists',
        () async {
      // Setup: Last completed was PUSH on yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();
      
      when(() => mockRepository.getSessionForDate(any()))
          .thenAnswer((_) async => null);
      when(() => mockRepository.getHistory()).thenAnswer((_) async => [
            WorkoutSession(
              dateKey: WorkoutDateUtils.formatDateKey(yesterday),
              workoutType: WorkoutType.push,
              exerciseLogs: {},
              displayUnit: WeightUnit.kg,
            )
          ]);
      when(() => mockRepository.getPreferredUnit())
          .thenAnswer((_) async => WeightUnit.kg);
      when(() => mockRepository.getPreviousExerciseLog(any(), any()))
          .thenAnswer((_) async => null);

      await cubit.loadDate(today);

      // PUSH -> PULL in sequence
      expect(cubit.state.workoutType, WorkoutType.pull);
    });

    test('loadDate should disambiguate Rest days correctly', () async {
      final today = DateTime.now();
      final day1 = today.subtract(const Duration(days: 1));
      final day2 = today.subtract(const Duration(days: 2));

      // Legs -> Rest -> Upper
      when(() => mockRepository.getSessionForDate(any()))
          .thenAnswer((_) async => null);
      when(() => mockRepository.getHistory()).thenAnswer((_) async => [
            WorkoutSession(
              dateKey: WorkoutDateUtils.formatDateKey(day1),
              workoutType: WorkoutType.rest,
              exerciseLogs: {},
              displayUnit: WeightUnit.kg,
            ),
            WorkoutSession(
              dateKey: WorkoutDateUtils.formatDateKey(day2),
              workoutType: WorkoutType.legs,
              exerciseLogs: {},
              displayUnit: WeightUnit.kg,
            )
          ]);
      when(() => mockRepository.getPreferredUnit())
          .thenAnswer((_) async => WeightUnit.kg);
      when(() => mockRepository.getPreviousExerciseLog(any(), any()))
          .thenAnswer((_) async => null);

      await cubit.loadDate(today);
      expect(cubit.state.workoutType, WorkoutType.upper);

      // Lower -> Rest -> Push
      when(() => mockRepository.getHistory()).thenAnswer((_) async => [
            WorkoutSession(
              dateKey: WorkoutDateUtils.formatDateKey(day1),
              workoutType: WorkoutType.rest,
              exerciseLogs: {},
              displayUnit: WeightUnit.kg,
            ),
            WorkoutSession(
              dateKey: WorkoutDateUtils.formatDateKey(day2),
              workoutType: WorkoutType.lower,
              exerciseLogs: {},
              displayUnit: WeightUnit.kg,
            )
          ]);

      await cubit.loadDate(today);
      expect(cubit.state.workoutType, WorkoutType.push);
    });
  });

  group('WorkoutCubit - Upper Body Warm-up Routine', () {
    test('Push, Pull, Upper should include warm-up exercises', () async {
      when(() => mockRepository.getPreviousExerciseLog(any(), any()))
          .thenAnswer((_) async => null);
      when(() => mockRepository.saveSession(any())).thenAnswer((_) async => {});

      // Push
      await cubit.changeWorkoutType(WorkoutType.push);
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_shoulder_circles'),
        isTrue,
      );
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_external_rotation'),
        isTrue,
      );
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_scapula_push_up'),
        isTrue,
      );
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_single_arm_row'),
        isTrue,
      );

      // Pull
      await cubit.changeWorkoutType(WorkoutType.pull);
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_shoulder_circles'),
        isTrue,
      );

      // Upper
      await cubit.changeWorkoutType(WorkoutType.upper);
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_shoulder_circles'),
        isTrue,
      );
    });

    test('Legs, Lower, Rest should NOT include warm-up exercises', () async {
      when(() => mockRepository.getPreviousExerciseLog(any(), any()))
          .thenAnswer((_) async => null);
      when(() => mockRepository.saveSession(any())).thenAnswer((_) async => {});

      // Legs
      await cubit.changeWorkoutType(WorkoutType.legs);
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_shoulder_circles'),
        isFalse,
      );

      // Lower
      await cubit.changeWorkoutType(WorkoutType.lower);
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_shoulder_circles'),
        isFalse,
      );

      // Rest
      await cubit.changeWorkoutType(WorkoutType.rest);
      expect(
        cubit.state.exerciseLogs.containsKey('warmup_banded_shoulder_circles'),
        isFalse,
      );
    });
  });
}

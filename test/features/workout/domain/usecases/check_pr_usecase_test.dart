import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/features/workout/domain/usecases/check_pr_usecase.dart';
import 'package:gym_tracker_report/features/workout/domain/usecases/get_exercise_history.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';

class MockGetExerciseHistory extends Mock implements GetExerciseHistory {}

void main() {
  late MockGetExerciseHistory mockGetHistory;
  late CheckPRUseCase usecase;

  setUp(() {
    mockGetHistory = MockGetExerciseHistory();
    usecase = CheckPRUseCase(mockGetHistory);
  });

  test('should return false if there is no history', () async {
    when(() => mockGetHistory.call(any(), any())).thenAnswer((_) async => []);

    final result = await usecase(
      exerciseId: 'test_id',
      weightKg: 100,
      actualReps: 5,
      currentDateKey: '2026-10-31',
    );

    expect(result, false);
  });

  test('should return true for a weight PR', () async {
    final entry = ExerciseHistoryEntry(
      dateKey: '2026-10-30',
      workoutTypeName: 'TypeA',
      log: ExerciseLog(
        plannedExerciseId: 'test_id',
        performedExerciseId: 'test_id',
        timestamp: DateTime.now(),
        sets: [
          ExerciseSetLog(weightKg: 80, actualReps: 5, isPerformed: true),
        ],
      ),
    );

    when(() => mockGetHistory.call(any(), any())).thenAnswer((_) async => [entry]);

    final result = await usecase(
      exerciseId: 'test_id',
      weightKg: 85, // New PR!
      actualReps: 5,
      currentDateKey: '2026-10-31',
    );

    expect(result, true);
  });

  test('should return true for a reps PR', () async {
    final entry = ExerciseHistoryEntry(
      dateKey: '2026-10-30',
      workoutTypeName: 'TypeA',
      log: ExerciseLog(
        plannedExerciseId: 'test_id',
        performedExerciseId: 'test_id',
        timestamp: DateTime.now(),
        sets: [
          ExerciseSetLog(weightKg: 80, actualReps: 5, isPerformed: true),
        ],
      ),
    );

    when(() => mockGetHistory.call(any(), any())).thenAnswer((_) async => [entry]);

    final result = await usecase(
      exerciseId: 'test_id',
      weightKg: 80,
      actualReps: 6, // New reps PR!
      currentDateKey: '2026-10-31',
    );

    expect(result, true);
  });
}

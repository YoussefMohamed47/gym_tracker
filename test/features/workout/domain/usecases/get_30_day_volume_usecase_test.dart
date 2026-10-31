import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/features/workout/domain/usecases/get_30_day_volume_usecase.dart';
import 'package:gym_tracker_report/features/workout/domain/repositories/workout_repository.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';
import 'package:gym_tracker_report/features/workout/utils/date_utils.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late MockWorkoutRepository repository;
  late Get30DayVolumeTonnageUseCase usecase;

  setUp(() {
    repository = MockWorkoutRepository();
    usecase = Get30DayVolumeTonnageUseCase(repository);
  });

  test('should aggregate correct volume for 30 days', () async {
    final now = DateTime.now();
    final todayStr = WorkoutDateUtils.formatDateKey(now);

    final session = WorkoutSession(
      dateKey: todayStr,
      workoutType: WorkoutType.chestAndBack,
      displayUnit: WeightUnit.kg,
      exerciseLogs: {
        'ex1': ExerciseLog(
          plannedExerciseId: 'ex1',
          performedExerciseId: 'ex1',
          timestamp: now,
          sets: [
            ExerciseSetLog(weightKg: 100, actualReps: 5, isPerformed: true), // 500
            ExerciseSetLog(weightKg: 100, actualReps: 5, isPerformed: true), // 500
          ],
        )
      },
    );

    when(() => repository.getHistory()).thenAnswer((_) async => [session]);

    final report = await usecase();
    expect(report.totalTonnage30Days, 1000.0);

    // There should be 30 points
    expect(report.points.length, 30);
    expect(report.points.last.tonnage, 1000.0);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';

ExerciseLog _log(List<ExerciseSetLog> sets) => ExerciseLog(
  plannedExerciseId: 'ex',
  performedExerciseId: 'ex',
  sets: sets,
  timestamp: DateTime(2026, 11, 14),
);

const _numbers = ExerciseSetLog(weightKg: 60, actualReps: 10);
const _done = ExerciseSetLog(weightKg: 60, actualReps: 10, isPerformed: true);

void main() {
  test('an unticked set with numbers before a ticked one is forgotten', () {
    expect(_log(const [_numbers, _done]).setLooksForgotten(0), isTrue);
  });

  test('prefilled sets ahead of you are not flagged', () {
    final log = _log(const [_done, _numbers, _numbers]);

    expect(log.setLooksForgotten(1), isFalse);
    expect(log.setLooksForgotten(2), isFalse);
  });

  test('an empty skipped set is not flagged', () {
    expect(_log(const [ExerciseSetLog(), _done]).setLooksForgotten(0), isFalse);
  });

  test('a ticked set is never flagged', () {
    expect(_log(const [_done, _done]).setLooksForgotten(0), isFalse);
  });

  test('an index outside the sets is not flagged', () {
    expect(_log(const [_done]).setLooksForgotten(3), isFalse);
  });
}

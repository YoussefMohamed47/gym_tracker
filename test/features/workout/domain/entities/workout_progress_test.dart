import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_progress.dart';

ExerciseLog _log(String id, {int sets = 2, int done = 0}) => ExerciseLog(
  plannedExerciseId: id,
  performedExerciseId: id,
  sets: [for (var i = 0; i < sets; i++) ExerciseSetLog(isPerformed: i < done)],
  timestamp: DateTime(2026, 11, 14),
);

Map<String, ExerciseLog> _logs(List<ExerciseLog> logs) => {
  for (final l in logs) l.plannedExerciseId: l,
};

void main() {
  const main = ['lift_a', 'lift_b'];

  test("counts only the day's own exercises", () {
    final progress = WorkoutProgress.fromLogs(
      _logs([
        _log('lift_a', sets: 3, done: 1),
        _log('lift_b', sets: 3),
        _log('warmup', sets: 2, done: 2),
        _log('routine', sets: 2, done: 2),
      ]),
      main,
    );

    expect(progress.doneSets, 1);
    expect(progress.totalSets, 6);
    expect(progress.doneExercises, 1);
    expect(progress.totalExercises, 2);
    expect(progress.exercisesNotDone, 1);
  });

  test('warm-up and routine sets do not start the lifts', () {
    final progress = WorkoutProgress.fromLogs(
      _logs([
        _log('lift_a'),
        _log('warmup', done: 2),
        _log('routine', done: 2),
      ]),
      main,
    );

    expect(progress.liftsStarted, isFalse);
  });

  test('a ticked main set starts the lifts', () {
    final progress = WorkoutProgress.fromLogs(
      _logs([_log('lift_a', done: 1)]),
      main,
    );

    expect(progress.liftsStarted, isTrue);
  });

  test('on a rest day the routine is counted but never starts lifts', () {
    final progress = WorkoutProgress.fromLogs(
      _logs([_log('routine', sets: 2, done: 1)]),
      const [],
    );

    expect(progress.doneSets, 1);
    expect(progress.totalSets, 2);
    expect(progress.liftsStarted, isFalse);
  });

  test('fractions are zero with nothing planned', () {
    final progress = WorkoutProgress.fromLogs(const {}, main);

    expect(progress.setFraction, 0);
    expect(progress.exerciseFraction, 0);
  });
}

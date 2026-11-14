import 'exercise_log.dart';

/// Progress through the day's own exercises. The daily routine and the
/// upper-body warm-up are left out, so the numbers match the main lifts.
class WorkoutProgress {
  final int doneSets;
  final int totalSets;
  final int doneExercises;
  final int totalExercises;

  /// False on a rest day, where the numbers are the routine's.
  final bool hasLifts;

  const WorkoutProgress({
    required this.doneSets,
    required this.totalSets,
    required this.doneExercises,
    required this.totalExercises,
    required this.hasLifts,
  });

  /// [mainExerciseIds] are the day's planned lifts; empty on a rest day,
  /// where every log (the routine) is the day's work.
  factory WorkoutProgress.fromLogs(
    Map<String, ExerciseLog> logs,
    List<String> mainExerciseIds,
  ) {
    final counted = mainExerciseIds.isEmpty
        ? logs.values.toList()
        : <ExerciseLog>[for (final id in mainExerciseIds) ?logs[id]];

    var doneSets = 0;
    var totalSets = 0;
    var doneExercises = 0;
    for (final log in counted) {
      totalSets += log.sets.length;
      final done = log.sets.where((s) => s.isPerformed).length;
      doneSets += done;
      if (done > 0) doneExercises++;
    }
    return WorkoutProgress(
      doneSets: doneSets,
      totalSets: totalSets,
      doneExercises: doneExercises,
      totalExercises: counted.length,
      hasLifts: mainExerciseIds.isNotEmpty,
    );
  }

  /// At least one main-lift set is ticked: warm-up time is over.
  bool get liftsStarted => hasLifts && doneSets > 0;

  /// Exercises counted here with no set done yet.
  int get exercisesNotDone => totalExercises - doneExercises;

  /// Share of main sets done, 0 to 1.
  double get setFraction => totalSets == 0 ? 0 : doneSets / totalSets;

  /// Share of main exercises with at least one set done, 0 to 1.
  double get exerciseFraction =>
      totalExercises == 0 ? 0 : doneExercises / totalExercises;
}

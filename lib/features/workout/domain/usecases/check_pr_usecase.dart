import 'get_exercise_history.dart';

class CheckPRUseCase {
  final GetExerciseHistory getExerciseHistory;

  CheckPRUseCase(this.getExerciseHistory);

  /// Checks if the provided weight or reps is a Personal Record (PR)
  /// for the given exercise.
  ///
  /// A set is considered a PR if:
  /// 1. There is historical data for the exercise (it's not the first time ever).
  /// 2. The weight is strictly greater than the maximum historical weight.
  /// 3. OR, the reps are strictly greater than the maximum historical reps (regardless of weight, or we could do at that weight).
  /// Let's use simple logic: strictly greater weight than ever recorded,
  /// OR strictly greater reps than ever recorded.
  Future<bool> call({
    required String exerciseId,
    required double? weightKg,
    required int? actualReps,
    required String currentDateKey, // To ignore current session in history
  }) async {
    if (weightKg == null && actualReps == null) return false;

    final history = await getExerciseHistory(
      '', // workoutTypeName not needed for this check as we filter by exerciseId internally
      exerciseId,
    );

    // Filter out the current session being edited
    final pastHistory = history.where((entry) => entry.dateKey != currentDateKey).toList();

    if (pastHistory.isEmpty) {
      // First time doing this exercise is not considered a "PR" visually to avoid spam
      // Or maybe it is? We'll return false to be conservative.
      return false;
    }

    double maxWeight = 0.0;
    int maxReps = 0;

    for (final entry in pastHistory) {
      // Check legacy single weight
      if (entry.log.weightKg != null && entry.log.isPerformed) {
        if (entry.log.weightKg! > maxWeight) {
          maxWeight = entry.log.weightKg!;
        }
      }

      // Check per-set data
      for (final set in entry.log.sets) {
        if (set.isPerformed) {
          if (set.weightKg != null && set.weightKg! > maxWeight) {
            maxWeight = set.weightKg!;
          }
          if (set.actualReps != null && set.actualReps! > maxReps) {
            maxReps = set.actualReps!;
          }
        }
      }
    }

    bool isWeightPR = weightKg != null && weightKg > maxWeight;
    bool isRepsPR = actualReps != null && actualReps > maxReps;

    return isWeightPR || isRepsPR;
  }
}

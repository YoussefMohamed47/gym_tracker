import '../models/volume_data_point.dart';
import '../repositories/workout_repository.dart';
import '../../utils/date_utils.dart';

class Get30DayVolumeTonnageUseCase {
  final WorkoutRepository repository;

  Get30DayVolumeTonnageUseCase(this.repository);

  Future<VolumeTonnageReport> call() async {
    final history = await repository.getHistory();

    // Create a map for the last 30 days initialized to 0
    final Map<String, double> dailyVolume = {};
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      dailyVolume[WorkoutDateUtils.formatDateKey(date)] = 0.0;
    }

    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    double totalTonnage = 0.0;

    for (final session in history) {
      final sessionDate = WorkoutDateUtils.parseDateKey(session.dateKey);
      if (sessionDate.isBefore(thirtyDaysAgo)) continue;

      if (!dailyVolume.containsKey(session.dateKey)) continue;

      double sessionTonnage = 0.0;

      for (final log in session.exerciseLogs.values) {
        for (final set in log.sets) {
          if (set.isPerformed && set.weightKg != null) {
            // Tonnage = Weight * Reps
            final reps = set.actualReps ?? 1; // fallback to 1 if no reps but weight
            final weight = set.weightKg!;
            sessionTonnage += (weight * reps);
          }
        }
      }

      dailyVolume[session.dateKey] = dailyVolume[session.dateKey]! + sessionTonnage;
      totalTonnage += sessionTonnage;
    }

    // Convert map to list sorted by date (oldest to newest)
    final points = dailyVolume.entries.map((entry) {
      return VolumeDataPoint(
        date: WorkoutDateUtils.parseDateKey(entry.key),
        tonnage: entry.value,
      );
    }).toList();

    points.sort((a, b) => a.date.compareTo(b.date));

    return VolumeTonnageReport(
      points: points,
      totalTonnage30Days: totalTonnage,
    );
  }
}

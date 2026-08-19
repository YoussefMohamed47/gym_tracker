import 'package:flutter/material.dart';
import '../../../../../../core/utils/weight_converter.dart';
import '../../../data/datasources/workout_catalog.dart';
import '../../../domain/entities/workout_session.dart';

class WeeklyWorkoutShareCard extends StatelessWidget {
  final List<WorkoutSession> weeklySessions;

  const WeeklyWorkoutShareCard({super.key, required this.weeklySessions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A46A0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'WEEKLY PROGRESS',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const Icon(
                Icons.calendar_view_week,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep Grinding',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          ...weeklySessions.map((session) => _buildSessionSummary(session)),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'GYM TRACKER',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSummary(WorkoutSession session) {
    final performedLogs = session.exerciseLogs.values
        .where((log) => log.isPerformed || log.sets.any((s) => s.isPerformed))
        .toList();

    if (performedLogs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${session.dateKey} — ${session.workoutType.name.toUpperCase()}',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...performedLogs.map((log) {
            final exercise = WorkoutCatalog.getExerciseById(
              log.performedExerciseId,
            );

            String summary = '';
            if (log.sets.isNotEmpty) {
              summary = log.sets
                  .where((s) => s.isPerformed)
                  .map((s) {
                    if (s.weightKg != null) {
                      final w = WeightConverter.convert(
                        s.weightKg!,
                        WeightUnit.kg,
                        log.displayUnit,
                      );
                      final ws = WeightConverter.format(w);
                      final unit = log.displayUnit.name;
                      return s.actualReps != null
                          ? '$ws$unit×${s.actualReps}'
                          : '$ws$unit';
                    } else if (s.actualReps != null) {
                      return '${s.actualReps}r';
                    }
                    return '✓';
                  })
                  .join(' • ');
            } else if (log.weightKg != null) {
              final w = WeightConverter.convert(
                log.weightKg!,
                WeightUnit.kg,
                log.displayUnit,
              );
              summary = '${WeightConverter.format(w)}kg';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    summary,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

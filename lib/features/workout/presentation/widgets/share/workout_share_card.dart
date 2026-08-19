import 'package:flutter/material.dart';
import '../../../../../../core/utils/weight_converter.dart';
import '../../../domain/entities/workout_session.dart';
import '../../../data/datasources/workout_catalog.dart';

class WorkoutShareCard extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutShareCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
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
                'WORKOUT COMPLETE',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const Icon(Icons.fitness_center, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            session.workoutType.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            session.dateKey,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          // Table Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'EXERCISE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'PERFORMANCE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...(() {
            final dailyRoutine = WorkoutCatalog.getDailyRoutine();
            final workoutDef = WorkoutCatalog.workouts.firstWhere(
              (w) => w.type == session.workoutType,
              orElse: () => WorkoutCatalog.workouts.first,
            );

            final orderedExerciseIds = [
              ...dailyRoutine.exercises.map((e) => e.exerciseId),
              ...workoutDef.exercises.map((e) => e.exerciseId),
            ];

            return orderedExerciseIds.map((plannedId) {
              final log = session.exerciseLogs[plannedId];
              if (log == null) return const SizedBox.shrink();

              final isPerformed =
                  log.isPerformed || log.sets.any((s) => s.isPerformed);
              if (!isPerformed) return const SizedBox.shrink();

              final exercise = WorkoutCatalog.getExerciseById(
                log.performedExerciseId,
              );

              List<String> performances = [];
              bool hasReps = false;

              if (log.sets.isNotEmpty) {
                for (int i = 0; i < log.sets.length; i++) {
                  final s = log.sets[i];
                  if (!s.isPerformed) continue;

                  String p = 'S${i + 1}: ';
                  if (s.weightKg != null) {
                    final w = WeightConverter.convert(
                      s.weightKg!,
                      WeightUnit.kg,
                      log.displayUnit,
                    );
                    p += WeightConverter.format(w);
                    if (s.actualReps != null) {
                      p += '×${s.actualReps}';
                      hasReps = true;
                    } else {
                      p += ' ${log.displayUnit.name}';
                    }
                  } else if (s.actualReps != null) {
                    p += '${s.actualReps}r';
                    hasReps = true;
                  } else {
                    p += '✓';
                  }
                  performances.add(p);
                }
              } else if (log.weightKg != null) {
                final w = WeightConverter.convert(
                  log.weightKg!,
                  WeightUnit.kg,
                  log.displayUnit,
                );
                performances.add(
                  '${WeightConverter.format(w)} ${log.displayUnit.name}',
                );
              }

              final performanceText = performances.join(' | ');

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            performanceText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          if (hasReps &&
                              !performanceText.contains(log.displayUnit.name))
                            Text(
                              log.displayUnit.name,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
          })(),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'GYM TRACKER',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

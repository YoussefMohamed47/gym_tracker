import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/workout_definition.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../../../core/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyRoutineSection extends StatelessWidget {
  const DailyRoutineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dailyRoutine = WorkoutCatalog.getDailyRoutine();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Daily Routine',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...dailyRoutine.exercises.map((slot) {
          return _DailyRoutineCard(slot: slot);
        }),
      ],
    );
  }
}

class _DailyRoutineCard extends StatelessWidget {
  final ExerciseSlot slot;

  const _DailyRoutineCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${slot.prescribedSets} sets • ${slot.prescribedReps} • Rest ${slot.prescribedRest}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (exercise.videoUrl != null)
                  IconButton(
                    icon: const Icon(
                      Icons.play_circle_outline,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                    onPressed: () async {
                      final url = Uri.parse(exercise.videoUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
              ],
            ),
            const Divider(height: 16),
            BlocBuilder<WorkoutCubit, WorkoutState>(
              builder: (context, state) {
                final log = state.exerciseLogs[slot.exerciseId];
                if (log == null) return const SizedBox.shrink();

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(slot.prescribedSets, (index) {
                    final isPerformed =
                        log.sets.length > index && log.sets[index].isPerformed;
                    return InkWell(
                      onTap: () => context
                          .read<WorkoutCubit>()
                          .toggleSetPerformed(slot.exerciseId, index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPerformed
                              ? AppColors.primaryBlue
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPerformed
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Set ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPerformed
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isPerformed
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isPerformed) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

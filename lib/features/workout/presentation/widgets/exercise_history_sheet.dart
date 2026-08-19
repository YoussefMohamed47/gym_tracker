import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/usecases/get_exercise_history.dart';

class ExerciseHistorySheet extends StatelessWidget {
  final String exerciseName;
  final List<ExerciseHistoryEntry> history;
  final WeightUnit displayUnit;

  const ExerciseHistorySheet({
    super.key,
    required this.exerciseName,
    required this.history,
    required this.displayUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'History',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No history found for this exercise.')),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: history.length,
                separatorBuilder: (_, _) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final entry = history[index];
                  final isLegacy =
                      entry.log.sets.isEmpty && entry.log.weightKg != null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.dateKey,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            entry.workoutTypeName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (isLegacy)
                        Row(
                          children: [
                            const Icon(
                              Icons.history,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Legacy working weight: ${WeightConverter.format(WeightConverter.convert(entry.log.weightKg!, WeightUnit.kg, displayUnit))} ${displayUnit.name}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.log.sets.asMap().entries.map((
                            setEntry,
                          ) {
                            final setIndex = setEntry.key;
                            final setLog = setEntry.value;
                            if (!setLog.isPerformed) {
                              return const SizedBox.shrink();
                            }

                            final weight = setLog.weightKg != null
                                ? WeightConverter.convert(
                                    setLog.weightKg!,
                                    WeightUnit.kg,
                                    displayUnit,
                                  )
                                : null;
                            final reps = setLog.actualReps;

                            String label = '';
                            if (weight != null) {
                              label =
                                  '${WeightConverter.format(weight)} ${displayUnit.name}';
                              if (reps != null) label += ' × $reps';
                            } else if (reps != null) {
                              label = '$reps reps';
                            } else {
                              label = 'Performed';
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                'S${setIndex + 1}: $label',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      if (entry.log.imagePath != null) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.fullScreenImage,
                              arguments: {
                                'imagePath': entry.log.imagePath,
                                'title': '$exerciseName • ${entry.dateKey}',
                              },
                            );
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(entry.log.imagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

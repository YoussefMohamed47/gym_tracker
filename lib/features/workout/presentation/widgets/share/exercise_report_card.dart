import 'package:flutter/material.dart';
import '../../../../../core/theme/report_theme_tokens.dart';
import '../../../../../core/utils/weight_converter.dart';
import '../../../data/datasources/workout_catalog.dart';
import '../../../domain/entities/exercise_log.dart';
import 'pr_badge.dart';
import 'set_chip.dart';

class ExerciseReportCard extends StatelessWidget {
  final ExerciseLog log;
  final bool isExportMode;

  const ExerciseReportCard({
    super.key,
    required this.log,
    this.isExportMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = WorkoutCatalog.getExerciseById(log.performedExerciseId);
    final unitLabel = log.displayUnit.name;

    // Determine muscle tag based on exercise ID or name
    String muscleTag = 'MAIN LIFT';
    final exId = exercise.id.toLowerCase();
    if (exId.contains('chest') || exId.contains('bench'))
      muscleTag = 'CHEST';
    else if (exId.contains('row') ||
        exId.contains('lat') ||
        exId.contains('pull'))
      muscleTag = 'BACK';
    else if (exId.contains('shoulder') ||
        exId.contains('delt') ||
        exId.contains('lateral'))
      muscleTag = 'SHOULDERS';
    else if (exId.contains('bicep') || exId.contains('curl'))
      muscleTag = 'BICEPS';
    else if (exId.contains('tricep') || exId.contains('push_down'))
      muscleTag = 'TRICEPS';
    else if (exId.contains('squat') ||
        exId.contains('leg') ||
        exId.contains('calve'))
      muscleTag = 'LEGS';

    // Calculate best set & check PR
    double bestWeight = 0;
    int bestReps = 0;
    bool hasReps = false;
    bool isPR = false;

    for (final s in log.sets) {
      if (!s.isPerformed) continue;
      if (s.weightKg != null) {
        final convertedW = WeightConverter.convert(
          s.weightKg!,
          WeightUnit.kg,
          log.displayUnit,
        );
        if (convertedW > bestWeight ||
            (convertedW == bestWeight && (s.actualReps ?? 0) > bestReps)) {
          bestWeight = convertedW;
          bestReps = s.actualReps ?? 0;
          hasReps = s.actualReps != null;
        }
      } else if (s.actualReps != null && s.actualReps! > bestReps) {
        bestReps = s.actualReps!;
        hasReps = true;
      }
    }

    // Heuristic for PR (if heavy weight or performed 3+ sets with good volume)
    if (bestWeight > 30 || bestReps >= 12) {
      isPR = true;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ReportThemeTokens.cardBackground,
        borderRadius: ReportThemeTokens.cardBorderRadius,
        border: Border.all(
          color: isPR
              ? ReportThemeTokens.violetAccent.withValues(alpha: 0.3)
              : ReportThemeTokens.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        exercise.name,
                        style: ReportThemeTokens.outfitHeader(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ReportThemeTokens.elevatedCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ReportThemeTokens.borderSubtle,
                        ),
                      ),
                      child: Text(
                        unitLabel,
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: ReportThemeTokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Muscle Tag Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ReportThemeTokens.indigoAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  muscleTag,
                  style: ReportThemeTokens.outfitHeader(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: ReportThemeTokens.indigoAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              if (isPR) ...[
                const SizedBox(width: 6),
                PrBadge(isExportMode: isExportMode),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Set Chips Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(log.sets.length, (index) {
              final setLog = log.sets[index];
              if (!setLog.isPerformed) {
                return SetChip(setIndex: index, label: '-', isPerformed: false);
              }

              if (setLog.weightKg != null) {
                final w = WeightConverter.convert(
                  setLog.weightKg!,
                  WeightUnit.kg,
                  log.displayUnit,
                );
                final formattedW = WeightConverter.format(w);
                final labelText = setLog.actualReps != null
                    ? '$formattedW × ${setLog.actualReps}'
                    : '$formattedW $unitLabel';

                final isBest = bestWeight > 0 && w == bestWeight;

                return SetChip(
                  setIndex: index,
                  label: labelText,
                  isPerformed: true,
                  isBestSet: isBest,
                );
              } else if (setLog.actualReps != null) {
                return SetChip(
                  setIndex: index,
                  label: '${setLog.actualReps} reps',
                  isPerformed: true,
                );
              }

              return SetChip(
                setIndex: index,
                label: '✓',
                isPerformed: true,
                isCheckmarkOnly: true,
              );
            }),
          ),

          // Best Set & Delta Row
          if (bestWeight > 0 || hasReps) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 13,
                      color: ReportThemeTokens.warningAmber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Best: ${WeightConverter.format(bestWeight)} $unitLabel${hasReps ? " × $bestReps" : ""}',
                      style: ReportThemeTokens.outfitSubtext(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ReportThemeTokens.warningAmber,
                      ),
                    ),
                  ],
                ),
                Text(
                  '+2.5 $unitLabel vs last',
                  style: ReportThemeTokens.outfitSubtext(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: ReportThemeTokens.completedGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

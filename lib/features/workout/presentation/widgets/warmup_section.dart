import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/plural.dart';
import '../../../../core/widgets/auto_fold.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_definition.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../utils/video_launcher.dart';
import 'set_check_button.dart';

class WarmupSection extends StatelessWidget {
  const WarmupSection({super.key});

  @override
  Widget build(BuildContext context) {
    final warmup = WorkoutCatalog.getUpperBodyWarmup();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (prev, curr) {
        // Rest-timer ticks keep the same logs: nothing to redo here.
        if (identical(prev.exerciseLogs, curr.exerciseLogs) &&
            prev.dateKey == curr.dateKey) {
          return false;
        }
        if (prev.dateKey != curr.dateKey ||
            prev.progress.liftsStarted != curr.progress.liftsStarted) {
          return true;
        }
        for (final slot in warmup.exercises) {
          if (prev.exerciseLogs[slot.exerciseId] !=
              curr.exerciseLogs[slot.exerciseId]) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        final totalWarmupItems = warmup.exercises.length;
        int completedWarmupItems = 0;

        for (final slot in warmup.exercises) {
          final log = state.exerciseLogs[slot.exerciseId];
          if (log != null &&
              log.sets.isNotEmpty &&
              log.sets.every((s) => s.isPerformed)) {
            completedWarmupItems++;
          }
        }

        final isAllComplete =
            totalWarmupItems > 0 && completedWarmupItems == totalWarmupItems;

        final progress = totalWarmupItems > 0
            ? completedWarmupItems / totalWarmupItems
            : 0.0;

        // Fold once done, or once the main lifts have started; a tap on the
        // header holds for the day it was made on.
        return AutoFold(
          resetKey: state.dateKey,
          shouldFold: isAllComplete || state.progress.liftsStarted,
          builder: (context, isExpanded, toggle) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isAllComplete
                    ? AppColors.completedGreen.withValues(alpha: 0.6)
                    : (isDark ? AppColors.borderSubtle : AppColors.outline),
                width: isAllComplete ? 1.5 : 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: [
                  // Collapsible Header Bar
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        toggle();
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isAllComplete
                                        ? AppColors.completedGreen.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.warmupOrange.withValues(
                                            alpha: 0.15,
                                          ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isAllComplete
                                        ? Icons.check_circle_rounded
                                        : Icons.local_fire_department_rounded,
                                    size: 18,
                                    color: isAllComplete
                                        ? AppColors.completedGreen
                                        : AppColors.warmupOrange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Upper Body Warm-up',
                                        style: ReportThemeTokens.outfitHeader(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: isAllComplete
                                              ? AppColors.completedGreen
                                              : (isDark
                                                    ? AppColors.textPrimary
                                                    : Colors.black87),
                                        ),
                                      ),
                                      Text(
                                        'Shoulder & Scapula activation before pressing',
                                        style: ReportThemeTokens.outfitSubtext(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAllComplete
                                        ? AppColors.completedGreen.withValues(
                                            alpha: 0.15,
                                          )
                                        : (isDark
                                              ? AppColors.darkElevated
                                              : AppColors.lightElevated),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$completedWarmupItems/$totalWarmupItems done',
                                    style: ReportThemeTokens.outfitNumber(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isAllComplete
                                          ? AppColors.completedGreen
                                          : (isDark
                                                ? AppColors.textPrimary
                                                : Colors.black87),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 3,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.black12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isAllComplete
                                      ? AppColors.completedGreen
                                      : AppColors.warmupOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Collapsible Cards List
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: warmup.exercises.map((slot) {
                          return _WarmupItemCard(slot: slot, isDark: isDark);
                        }).toList(),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WarmupItemCard extends StatelessWidget {
  final ExerciseSlot slot;
  final bool isDark;

  const _WarmupItemCard({required this.slot, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (prev, curr) =>
          prev.exerciseLogs[slot.exerciseId] !=
          curr.exerciseLogs[slot.exerciseId],
      builder: (context, state) {
        final log = state.exerciseLogs[slot.exerciseId];
        final isCompleted =
            log != null &&
            log.sets.isNotEmpty &&
            log.sets.every((s) => s.isPerformed);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.completedGreen.withValues(alpha: 0.05)
                : (isDark ? AppColors.darkElevated : AppColors.lightInset),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppColors.completedGreen.withValues(alpha: 0.35)
                  : (isDark ? AppColors.borderSubtle : AppColors.outline),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            style: ReportThemeTokens.outfitHeader(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isCompleted
                                  ? AppColors.completedGreen
                                  : (isDark
                                        ? AppColors.textPrimary
                                        : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${countOf(slot.prescribedSets, 'set')} × ${slot.prescribedReps}',
                            style: ReportThemeTokens.outfitSubtext(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (exercise.videoUrl != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              VideoLauncher.launch(context, exercise.videoUrl!),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warmupOrange.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.warmupOrange.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 14,
                                  color: AppColors.warmupOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Guide',
                                  style: ReportThemeTokens.outfitSubtext(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warmupOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Same set buttons as the daily routine.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(slot.prescribedSets, (setIdx) {
                    final setLog = (log != null && log.sets.length > setIdx)
                        ? log.sets[setIdx]
                        : null;
                    return SetCheckButton(
                      exerciseId: slot.exerciseId,
                      setIndex: setIdx,
                      isPerformed: setLog?.isPerformed ?? false,
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_definition.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../utils/video_launcher.dart';

class WarmupSection extends StatefulWidget {
  const WarmupSection({super.key});

  @override
  State<WarmupSection> createState() => _WarmupSectionState();
}

class _WarmupSectionState extends State<WarmupSection> {
  bool _isExpanded = true;
  bool _hasAutoCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final warmup = WorkoutCatalog.getUpperBodyWarmup();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (prev, curr) {
        for (final slot in warmup.exercises) {
          if (prev.exerciseLogs[slot.exerciseId] != curr.exerciseLogs[slot.exerciseId]) {
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
          if (log != null && log.sets.isNotEmpty && log.sets.every((s) => s.isPerformed)) {
            completedWarmupItems++;
          }
        }

        final isAllComplete = totalWarmupItems > 0 && completedWarmupItems == totalWarmupItems;

        if (isAllComplete && !_hasAutoCollapsed && _isExpanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isExpanded = false;
                _hasAutoCollapsed = true;
              });
            }
          });
        }

        final progress = totalWarmupItems > 0 ? completedWarmupItems / totalWarmupItems : 0.0;

        return Container(
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
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
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
                                      ? AppColors.completedGreen.withValues(alpha: 0.15)
                                      : const Color(0xFFFF9500).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAllComplete ? Icons.check_circle_rounded : Icons.local_fire_department_rounded,
                                  size: 18,
                                  color: isAllComplete ? AppColors.completedGreen : const Color(0xFFFF9500),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upper Body Warm-up',
                                      style: ReportThemeTokens.outfitHeader(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: isAllComplete
                                            ? AppColors.completedGreen
                                            : (isDark ? AppColors.textPrimary : Colors.black87),
                                      ),
                                    ),
                                    Text(
                                      'Shoulder & Scapula activation before pressing',
                                      style: ReportThemeTokens.outfitSubtext(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAllComplete
                                      ? AppColors.completedGreen.withValues(alpha: 0.15)
                                      : (isDark ? AppColors.darkElevated : const Color(0xFFF0F2F7)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$completedWarmupItems/$totalWarmupItems done',
                                  style: ReportThemeTokens.outfitNumber(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isAllComplete
                                        ? AppColors.completedGreen
                                        : (isDark ? AppColors.textPrimary : Colors.black87),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0.0,
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
                              backgroundColor: isDark ? Colors.white10 : Colors.black12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isAllComplete ? AppColors.completedGreen : const Color(0xFFFF9500),
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
                  crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
        );
      },
    );
  }
}

class _WarmupItemCard extends StatelessWidget {
  final ExerciseSlot slot;
  final bool isDark;

  const _WarmupItemCard({
    required this.slot,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (prev, curr) =>
          prev.exerciseLogs[slot.exerciseId] != curr.exerciseLogs[slot.exerciseId],
      builder: (context, state) {
        final log = state.exerciseLogs[slot.exerciseId];
        final isCompleted = log != null &&
            log.sets.isNotEmpty &&
            log.sets.every((s) => s.isPerformed);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.completedGreen.withValues(alpha: 0.05)
                : (isDark ? AppColors.darkElevated : const Color(0xFFF7F8FC)),
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
                                  : (isDark ? AppColors.textPrimary : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${slot.prescribedSets} sets × ${slot.prescribedReps}',
                            style: ReportThemeTokens.outfitSubtext(
                              fontSize: 11,
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
                          onTap: () => VideoLauncher.launch(context, exercise.videoUrl!),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 14,
                                  color: Color(0xFFFF9500),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Guide',
                                  style: ReportThemeTokens.outfitSubtext(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF9500),
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

                // Set check circles row
                Row(
                  children: List.generate(slot.prescribedSets, (setIdx) {
                    final setLog = (log != null && log.sets.length > setIdx) ? log.sets[setIdx] : null;
                    final isSetDone = setLog?.isPerformed ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.read<WorkoutCubit>().toggleSetPerformed(slot.exerciseId, setIdx);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSetDone
                                ? AppColors.completedGreen
                                : (isDark ? AppColors.darkCard : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSetDone
                                  ? AppColors.completedGreen
                                  : (isDark ? AppColors.borderSubtle : AppColors.outline),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSetDone ? Icons.check_rounded : Icons.circle_outlined,
                                size: 14,
                                color: isSetDone ? Colors.black : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Set ${setIdx + 1}',
                                style: ReportThemeTokens.outfitNumber(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSetDone ? Colors.black : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

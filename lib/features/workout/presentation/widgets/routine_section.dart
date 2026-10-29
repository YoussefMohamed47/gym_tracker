import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_catalog.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/workout_definition.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../utils/video_launcher.dart';

class RoutineSection extends StatefulWidget {
  const RoutineSection({super.key});

  @override
  State<RoutineSection> createState() => _RoutineSectionState();
}

class _RoutineSectionState extends State<RoutineSection> {
  bool _isExpanded = true;
  bool _hasAutoCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final dailyRoutine = WorkoutCatalog.getDailyRoutine();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (prev, curr) {
        // Only rebuild if routine logs changed
        for (final slot in dailyRoutine.exercises) {
          if (prev.exerciseLogs[slot.exerciseId] != curr.exerciseLogs[slot.exerciseId]) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        final totalRoutineItems = dailyRoutine.exercises.length;
        int completedRoutineItems = 0;

        for (final slot in dailyRoutine.exercises) {
          final log = state.exerciseLogs[slot.exerciseId];
          if (log != null && log.sets.isNotEmpty && log.sets.every((s) => s.isPerformed)) {
            completedRoutineItems++;
          }
        }

        final isAllComplete = totalRoutineItems > 0 && completedRoutineItems == totalRoutineItems;

        // Auto-collapse once all completed if not already collapsed
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

        final progress = totalRoutineItems > 0 ? completedRoutineItems / totalRoutineItems : 0.0;

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
                                      : AppColors.indigoAccent.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAllComplete ? Icons.check_circle_rounded : Icons.accessibility_new_rounded,
                                  size: 18,
                                  color: isAllComplete ? AppColors.completedGreen : AppColors.indigoAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Warm-up & Rehab (Daily Routine)',
                                      style: ReportThemeTokens.outfitHeader(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: isAllComplete
                                            ? AppColors.completedGreen
                                            : (isDark ? AppColors.textPrimary : Colors.black87),
                                      ),
                                    ),
                                    Text(
                                      '$completedRoutineItems of $totalRoutineItems done',
                                      style: ReportThemeTokens.outfitSubtext(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: isDark ? Colors.white10 : Colors.black12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isAllComplete ? AppColors.completedGreen : AppColors.indigoAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Collapsible Body
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Column(
                          children: [
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark ? AppColors.borderSubtle : AppColors.outline,
                            ),
                            ...dailyRoutine.exercises.map((slot) {
                              return _RoutineItemCard(slot: slot);
                            }),
                            const SizedBox(height: 8),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoutineItemCard extends StatelessWidget {
  final ExerciseSlot slot;

  const _RoutineItemCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);
    final isDurationBased = slot.prescribedReps.contains('s');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (prev, curr) =>
          prev.exerciseLogs[slot.exerciseId] != curr.exerciseLogs[slot.exerciseId],
      builder: (context, state) {
        final log = state.exerciseLogs[slot.exerciseId];
        final isFullyDone = log != null && log.sets.isNotEmpty && log.sets.every((s) => s.isPerformed);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFullyDone
                  ? AppColors.completedGreen.withValues(alpha: 0.5)
                  : (isDark ? AppColors.borderSubtle : AppColors.outline),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Green Left Accent Line when fully done
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isFullyDone ? 4 : 0,
                    color: AppColors.completedGreen,
                  ),
                  Expanded(
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
                                      style: ReportThemeTokens.outfitHeader(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isFullyDone
                                            ? AppColors.completedGreen
                                            : (isDark ? AppColors.textPrimary : Colors.black87),
                                      ),
                                    ),
                                    Text(
                                      '${slot.prescribedSets} sets • ${slot.prescribedReps} • Rest ${slot.prescribedRest}',
                                      style: ReportThemeTokens.outfitSubtext(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (exercise.videoUrl != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 24,
                                    color: AppColors.indigoAccent,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  onPressed: () => VideoLauncher.launch(context, exercise.videoUrl!),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Large Tappable Set Circles (min 48px touch target)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(slot.prescribedSets, (index) {
                              final setLog = (log != null && log.sets.length > index)
                                  ? log.sets[index]
                                  : null;
                              final isPerformed = setLog?.isPerformed ?? false;

                              if (isDurationBased) {
                                return _TimedSetCircle(
                                  exerciseId: slot.exerciseId,
                                  setIndex: index,
                                  prescribedReps: slot.prescribedReps,
                                  isPerformed: isPerformed,
                                );
                              }

                              return _StandardSetCircle(
                                exerciseId: slot.exerciseId,
                                setIndex: index,
                                isPerformed: isPerformed,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
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

class _StandardSetCircle extends StatelessWidget {
  final String exerciseId;
  final int setIndex;
  final bool isPerformed;

  const _StandardSetCircle({
    required this.exerciseId,
    required this.setIndex,
    required this.isPerformed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.mediumImpact();
          context.read<WorkoutCubit>().toggleSetPerformed(exerciseId, setIndex);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 48,
          decoration: BoxDecoration(
            color: isPerformed
                ? AppColors.completedGreen
                : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPerformed
                  ? AppColors.completedGreen
                  : (isDark ? AppColors.borderSubtle : AppColors.outline),
              width: 1.5,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: isPerformed
                  ? const Icon(
                      Icons.check_rounded,
                      key: ValueKey('done'),
                      size: 20,
                      color: Colors.black,
                    )
                  : Text(
                      'S${setIndex + 1}',
                      key: const ValueKey('undone'),
                      style: ReportThemeTokens.outfitNumber(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimary : Colors.black87,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimedSetCircle extends StatefulWidget {
  final String exerciseId;
  final int setIndex;
  final String prescribedReps;
  final bool isPerformed;

  const _TimedSetCircle({
    required this.exerciseId,
    required this.setIndex,
    required this.prescribedReps,
    required this.isPerformed,
  });

  @override
  State<_TimedSetCircle> createState() => _TimedSetCircleState();
}

class _TimedSetCircleState extends State<_TimedSetCircle> {
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  bool _isRunning = false;

  int _parseDurationSeconds() {
    final digits = RegExp(r'\d+').firstMatch(widget.prescribedReps)?.group(0);
    return int.tryParse(digits ?? '') ?? 10;
  }

  void _startTimer() {
    final target = _parseDurationSeconds();
    setState(() {
      _secondsRemaining = target;
      _isRunning = true;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _isRunning = false;
        });
        HapticFeedback.heavyImpact();
        context.read<WorkoutCubit>().toggleSetPerformed(widget.exerciseId, widget.setIndex);
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final target = _parseDurationSeconds();
    final progress = target > 0 ? (_secondsRemaining / target) : 0.0;

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.isPerformed) {
            HapticFeedback.mediumImpact();
            context.read<WorkoutCubit>().toggleSetPerformed(widget.exerciseId, widget.setIndex);
          } else if (!_isRunning) {
            HapticFeedback.lightImpact();
            _startTimer();
          } else {
            // Cancel running timer
            _countdownTimer?.cancel();
            setState(() {
              _isRunning = false;
              _secondsRemaining = 0;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 58,
          height: 48,
          decoration: BoxDecoration(
            color: widget.isPerformed
                ? AppColors.completedGreen
                : _isRunning
                    ? AppColors.warningAmber.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPerformed
                  ? AppColors.completedGreen
                  : _isRunning
                      ? AppColors.warningAmber
                      : (isDark ? AppColors.borderSubtle : AppColors.outline),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isRunning)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warningAmber),
                    backgroundColor: Colors.white12,
                  ),
                ),
              if (widget.isPerformed)
                const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: Colors.black,
                )
              else if (_isRunning)
                Text(
                  '${_secondsRemaining}s',
                  style: ReportThemeTokens.outfitNumber(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.warningAmber,
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: AppColors.indigoAccent,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'S${widget.setIndex + 1}',
                      style: ReportThemeTokens.outfitNumber(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimary : Colors.black87,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

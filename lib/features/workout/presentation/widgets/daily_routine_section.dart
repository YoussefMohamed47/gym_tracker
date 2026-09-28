import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_definition.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../utils/video_launcher.dart';

class DailyRoutineSection extends StatefulWidget {
  const DailyRoutineSection({super.key});

  @override
  State<DailyRoutineSection> createState() => _DailyRoutineSectionState();
}

class _DailyRoutineSectionState extends State<DailyRoutineSection> {
  bool _isExpanded = true;
  bool _hasAutoCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final dailyRoutine = WorkoutCatalog.getDailyRoutine();

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        int totalRoutineItems = dailyRoutine.exercises.length;
        int completedRoutineItems = 0;

        for (final slot in dailyRoutine.exercises) {
          final log = state.exerciseLogs[slot.exerciseId];
          if (log != null &&
              log.sets.isNotEmpty &&
              log.sets.every((s) => s.isPerformed)) {
            completedRoutineItems++;
          }
        }

        final isAllComplete =
            totalRoutineItems > 0 && completedRoutineItems == totalRoutineItems;

        // Auto-collapse once all completed if not already done
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

        final progress = totalRoutineItems > 0
            ? completedRoutineItems / totalRoutineItems
            : 0.0;

        final isDark = Theme.of(context).brightness == Brightness.dark;

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
                // Header Bar with Progress & Expand Toggle
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
                    highlightColor: AppColors.gradientStart.withValues(alpha: 0.08),
                    splashColor: AppColors.gradientStart.withValues(alpha: 0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isAllComplete
                                      ? AppColors.completedGreen.withValues(alpha: 0.15)
                                      : AppColors.gradientStart.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAllComplete
                                      ? Icons.check_circle_rounded
                                      : Icons.accessibility_new_rounded,
                                  size: 18,
                                  color: isAllComplete
                                      ? AppColors.completedGreen
                                      : AppColors.gradientStart,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Warm-up & Rehab',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: isAllComplete
                                            ? AppColors.completedGreen
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '$completedRoutineItems of $totalRoutineItems done',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor:
                                  isDark ? Colors.white10 : Colors.black12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isAllComplete
                                    ? AppColors.completedGreen
                                    : AppColors.gradientStart,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Collapsible List Body
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Column(
                          children: [
                            const Divider(height: 1, thickness: 1),
                            ...dailyRoutine.exercises.map((slot) {
                              return _DailyRoutineCard(slot: slot);
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

class _DailyRoutineCard extends StatelessWidget {
  final ExerciseSlot slot;

  const _DailyRoutineCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);
    final isDurationBased = slot.prescribedReps.contains('s');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        final log = state.exerciseLogs[slot.exerciseId];
        final isFullyDone = log != null &&
            log.sets.isNotEmpty &&
            log.sets.every((s) => s.isPerformed);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFullyDone
                  ? AppColors.completedGreen.withValues(alpha: 0.5)
                  : (isDark ? AppColors.borderSubtle : AppColors.outline),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Green Left Accent Line when done
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
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
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isFullyDone
                                            ? AppColors.completedGreen
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${slot.prescribedSets} sets • ${slot.prescribedReps} • Rest ${slot.prescribedRest}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (exercise.videoUrl != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 22,
                                    color: AppColors.gradientStart,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => VideoLauncher.launch(
                                    context,
                                    exercise.videoUrl!,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Circular Tap Set Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(slot.prescribedSets, (index) {
                              final setLog = (log != null && log.sets.length > index)
                                  ? log.sets[index]
                                  : null;
                              final isPerformed = setLog?.isPerformed ?? false;

                              if (isDurationBased) {
                                return _TimedSetChip(
                                  exerciseId: slot.exerciseId,
                                  setIndex: index,
                                  prescribedReps: slot.prescribedReps,
                                  isPerformed: isPerformed,
                                );
                              }

                              return _StandardRoutineSetChip(
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

class _StandardRoutineSetChip extends StatelessWidget {
  final String exerciseId;
  final int setIndex;
  final bool isPerformed;

  const _StandardRoutineSetChip({
    required this.exerciseId,
    required this.setIndex,
    required this.isPerformed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<WorkoutCubit>().toggleSetPerformed(exerciseId, setIndex);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 52,
        height: 38,
        decoration: BoxDecoration(
          color: isPerformed
              ? AppColors.completedGreen
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPerformed
                ? AppColors.completedGreen
                : (isDark ? AppColors.borderSubtle : AppColors.outline),
            width: 1.5,
          ),
          boxShadow: isPerformed
              ? [
                  BoxShadow(
                    color: AppColors.completedGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPerformed) ...[
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.black,
              ),
            ] else ...[
              Text(
                'S${setIndex + 1}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimedSetChip extends StatefulWidget {
  final String exerciseId;
  final int setIndex;
  final String prescribedReps;
  final bool isPerformed;

  const _TimedSetChip({
    required this.exerciseId,
    required this.setIndex,
    required this.prescribedReps,
    required this.isPerformed,
  });

  @override
  State<_TimedSetChip> createState() => _TimedSetChipState();
}

class _TimedSetChipState extends State<_TimedSetChip> {
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
        HapticFeedback.vibrate();
        context
            .read<WorkoutCubit>()
            .toggleSetPerformed(widget.exerciseId, widget.setIndex);
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
    final targetSecs = _parseDurationSeconds();
    final progress = _isRunning ? (_secondsRemaining / targetSecs) : 0.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (_isRunning) {
          _countdownTimer?.cancel();
          setState(() {
            _isRunning = false;
          });
        } else if (widget.isPerformed) {
          context
              .read<WorkoutCubit>()
              .toggleSetPerformed(widget.exerciseId, widget.setIndex);
        } else {
          _startTimer();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isPerformed
              ? AppColors.completedGreen
              : (_isRunning
                  ? AppColors.restAmber.withValues(alpha: 0.15)
                  : (isDark ? AppColors.darkCard : Colors.white)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isPerformed
                ? AppColors.completedGreen
                : (_isRunning
                    ? AppColors.restAmber
                    : (isDark ? AppColors.borderSubtle : AppColors.outline)),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRunning) ...[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation(AppColors.restAmber),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_secondsRemaining}s',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.restAmber,
                ),
              ),
            ] else if (widget.isPerformed) ...[
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.black,
              ),
              const SizedBox(width: 4),
              Text(
                'S${widget.setIndex + 1}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ] else ...[
              const Icon(
                Icons.timer_outlined,
                size: 14,
                color: AppColors.gradientStart,
              ),
              const SizedBox(width: 4),
              Text(
                'S${widget.setIndex + 1} (${targetSecs}s)',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

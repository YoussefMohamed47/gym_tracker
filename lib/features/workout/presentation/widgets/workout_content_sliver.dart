import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import 'daily_routine_section.dart';
import 'warmup_section.dart';
import 'exercise_log_card.dart';
import 'workout_switcher_sheet.dart';

class WorkoutContentSliver extends StatefulWidget {
  final WorkoutState state;
  final Function(String plannedId, String currentPerformedId)
      onSelectAlternative;
  final Function(String exerciseId) onAddPhoto;
  final Function(String exerciseId, String name) onShowHistory;

  const WorkoutContentSliver({
    super.key,
    required this.state,
    required this.onSelectAlternative,
    required this.onAddPhoto,
    required this.onShowHistory,
  });

  @override
  State<WorkoutContentSliver> createState() => _WorkoutContentSliverState();
}

class _WorkoutContentSliverState extends State<WorkoutContentSliver> {
  int _expandedIndex = 0;

  void _onSetPerformedToggle(
    String exerciseId,
    int setIndex,
    int exerciseIndex,
    int totalExercises,
  ) {
    final cubit = context.read<WorkoutCubit>();
    cubit.toggleSetPerformed(exerciseId, setIndex);

    // Auto-advance check: if completing the last set of current exercise, auto-expand next exercise
    final log = widget.state.exerciseLogs[exerciseId];
    if (log != null && log.sets.length > setIndex) {
      final updatedPerformedCount =
          log.sets.where((s) => s.isPerformed).length +
              (log.sets[setIndex].isPerformed ? -1 : 1);

      if (updatedPerformedCount == log.sets.length &&
          exerciseIndex < totalExercises - 1) {
        setState(() {
          _expandedIndex = exerciseIndex + 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Loading State with Shimmer Skeletons
    if (widget.state.status == WorkoutStatus.loading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.outline,
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1200.ms, color: Colors.white12);
          },
          childCount: 4,
        ),
      );
    }

    final workoutDef = WorkoutCatalog.getWorkoutByType(widget.state.workoutType);

    return SliverMainAxisGroup(
      slivers: [
        // Rest Day Empty State
        if (widget.state.workoutType == WorkoutType.rest)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gradientStart.withValues(alpha: 0.1),
                    AppColors.gradientEnd.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.gradientStart.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.completedGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      size: 38,
                      color: AppColors.completedGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rest & Recovery',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.completedGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enjoy your recovery! Muscle grows during rest. Focus on hydration, mobility, and high-quality protein today.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => WorkoutSwitcherSheet.show(context),
                    icon: const Icon(Icons.fitness_center_rounded, size: 16),
                    label: const Text('Start a workout anyway'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientStart,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Warm-up & Rehab Section
        const SliverToBoxAdapter(child: DailyRoutineSection()),
        if (widget.state.workoutType.isUpperBody)
          const SliverToBoxAdapter(child: WarmupSection()),

        // Main Exercises Section
        if (widget.state.workoutType != WorkoutType.rest &&
            workoutDef != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(
                    'WORKOUT',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gradientStart.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${workoutDef.exercises.length}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gradientStart,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final slot = workoutDef.exercises[index];
                final log = widget.state.exerciseLogs[slot.exerciseId];
                if (log == null) return const SizedBox.shrink();

                final performedExercise = WorkoutCatalog.getExerciseById(
                  log.performedExerciseId,
                );

                return ExerciseLogCard(
                  log: log,
                  slot: slot,
                  displayUnit: widget.state.displayUnit,
                  isExpanded: index == _expandedIndex,
                  onExpandToggle: () {
                    setState(() {
                      _expandedIndex = _expandedIndex == index ? -1 : index;
                    });
                  },
                  onWeightChanged: (setIndex, weight) {
                    context.read<WorkoutCubit>().updateSetWeight(
                          slot.exerciseId,
                          setIndex,
                          weight,
                          log.displayUnit,
                        );
                  },
                  onRepsChanged: (setIndex, reps) {
                    context.read<WorkoutCubit>().updateSetReps(
                          slot.exerciseId,
                          setIndex,
                          reps,
                        );
                  },
                  onStepWeight: (setIndex, delta) {
                    context.read<WorkoutCubit>().stepWeight(
                          slot.exerciseId,
                          setIndex,
                          delta,
                        );
                  },
                  onStepReps: (setIndex, delta) {
                    context.read<WorkoutCubit>().stepReps(
                          slot.exerciseId,
                          setIndex,
                          delta,
                        );
                  },
                  onToggleSetPerformed: (setIndex) {
                    _onSetPerformedToggle(
                      slot.exerciseId,
                      setIndex,
                      index,
                      workoutDef.exercises.length,
                    );
                  },
                  onUnitChanged: (unit) {
                    context.read<WorkoutCubit>().updateExerciseUnit(
                          slot.exerciseId,
                          unit,
                        );
                  },
                  onSelectAlternative: () => widget.onSelectAlternative(
                    slot.exerciseId,
                    log.performedExerciseId,
                  ),
                  onAddPhoto: () => widget.onAddPhoto(slot.exerciseId),
                  onShowHistory: () => widget.onShowHistory(
                    log.performedExerciseId,
                    performedExercise.name,
                  ),
                  onUseLegacyWeight: () => context
                      .read<WorkoutCubit>()
                      .useLegacyWeightForAllSets(slot.exerciseId),
                  onCopyPreviousSession: () => context
                      .read<WorkoutCubit>()
                      .copyPreviousSession(slot.exerciseId),
                  onAddSet: () =>
                      context.read<WorkoutCubit>().addSet(slot.exerciseId),
                  onRemoveSet: (setIndex) => context
                      .read<WorkoutCubit>()
                      .removeSet(slot.exerciseId, setIndex),
                ).animate().fadeIn(
                      duration: 300.ms,
                      delay: (40 * index).ms,
                    ).slideY(
                      begin: 0.1,
                      end: 0.0,
                      curve: Curves.easeOutCubic,
                    );
              },
              childCount: workoutDef.exercises.length,
            ),
          ),
        ] else if (widget.state.workoutType != WorkoutType.rest &&
            workoutDef == null)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No workout definition found.')),
            ),
          ),
      ],
    );
  }
}

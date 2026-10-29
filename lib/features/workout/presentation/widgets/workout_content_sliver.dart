import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import 'day_picker_sheet.dart';
import 'exercise_card.dart';
import 'routine_section.dart';
import 'warmup_section.dart';

class WorkoutContentSliver extends StatefulWidget {
  final WorkoutState state;
  final Function(String plannedId, String currentPerformedId) onSelectAlternative;
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
      final willBePerformed = !log.sets[setIndex].isPerformed;
      final previouslyPerformedCount = log.sets.where((s) => s.isPerformed).length;
      final newPerformedCount = previouslyPerformedCount + (willBePerformed ? 1 : -1);

      if (newPerformedCount == log.sets.length && exerciseIndex < totalExercises - 1) {
        setState(() {
          _expandedIndex = exerciseIndex + 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Loading State
    if (widget.state.status == WorkoutStatus.loading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.outline,
                ),
              ),
            );
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
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.outline,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.completedGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      size: 34,
                      color: AppColors.completedGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Rest & Recovery',
                    style: ReportThemeTokens.outfitHeader(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.completedGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enjoy your recovery! Muscle grows during rest. Focus on hydration, mobility, and high-quality protein today.',
                    textAlign: TextAlign.center,
                    style: ReportThemeTokens.outfitSubtext(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () => DayPickerSheet.show(context),
                    icon: const Icon(Icons.fitness_center_rounded, size: 16),
                    label: const Text('Start a workout anyway'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigoAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Warm-up & Rehab Section (Reskinned, same data/logic)
        const SliverToBoxAdapter(child: RoutineSection()),
        if (widget.state.workoutType.isUpperBody)
          const SliverToBoxAdapter(child: WarmupSection()),

        // Main Exercises Section (Focus Mode)
        if (widget.state.workoutType != WorkoutType.rest && workoutDef != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'WORKOUT EXERCISES',
                    style: ReportThemeTokens.outfitHeader(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.indigoAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${workoutDef.exercises.length}',
                      style: ReportThemeTokens.outfitNumber(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.indigoAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: workoutDef.exercises.length,
            itemBuilder: (context, index) {
              final slot = workoutDef.exercises[index];
              final log = widget.state.exerciseLogs[slot.exerciseId];
              if (log == null) return const SizedBox.shrink();

              final performedExercise = WorkoutCatalog.getExerciseById(log.performedExerciseId);

              return ExerciseCard(
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
                onCopyPreviousSession: () =>
                    context.read<WorkoutCubit>().copyPreviousSession(slot.exerciseId),
                onAddSet: () => context.read<WorkoutCubit>().addSet(slot.exerciseId),
                onRemoveSet: (setIndex) =>
                    context.read<WorkoutCubit>().removeSet(slot.exerciseId, setIndex),
              );
            },
          ),
        ] else if (widget.state.workoutType != WorkoutType.rest && workoutDef == null)
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

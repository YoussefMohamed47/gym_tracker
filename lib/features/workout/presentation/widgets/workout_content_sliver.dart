import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_definition.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import 'day_picker_sheet.dart';
import 'exercise_card.dart';
import 'last_time_panel.dart';
import 'routine_section.dart';
import 'warmup_section.dart';

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

  @override
  void didUpdateWidget(covariant WorkoutContentSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.dateKey != widget.state.dateKey ||
        oldWidget.state.workoutType != widget.state.workoutType) {
      _expandedIndex = 0;
    }
  }

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
      final previouslyPerformedCount = log.sets
          .where((s) => s.isPerformed)
          .length;
      final newPerformedCount =
          previouslyPerformedCount + (willBePerformed ? 1 : -1);

      if (newPerformedCount == log.sets.length &&
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

    // Loading State
    if (widget.state.status == WorkoutStatus.loading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
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
        }, childCount: 4),
      );
    }

    final workoutDef = WorkoutCatalog.getWorkoutByType(
      widget.state.workoutType,
    );

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

        // Warm-up & Rehab Section (Reskinned, same data/logic)
        const SliverToBoxAdapter(child: RoutineSection()),
        if (widget.state.workoutType.isUpperBody)
          const SliverToBoxAdapter(child: WarmupSection()),

        // Main Exercises Section (Focus Mode)
        if (widget.state.workoutType != WorkoutType.rest &&
            workoutDef != null &&
            workoutDef.exercises.isNotEmpty) ...[
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
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
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      Text(
                        'EXERCISE FOCUS',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_expandedIndex.clamp(0, workoutDef.exercises.length - 1) + 1} / ${workoutDef.exercises.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: workoutDef.exercises.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final slot = workoutDef.exercises[index];
                      final log = widget.state.exerciseLogs[slot.exerciseId];
                      final done =
                          log != null &&
                          log.sets.isNotEmpty &&
                          log.sets.every((s) => s.isPerformed);
                      final selected = index == _expandedIndex;
                      final colors = Theme.of(context).colorScheme;
                      return Material(
                        color: selected ? colors.primary : colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => setState(() => _expandedIndex = index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 185,
                            padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '0${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: selected
                                            ? colors.onPrimary
                                            : colors.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (done)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 16,
                                        color: selected
                                            ? colors.onPrimary
                                            : colors.primary,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  log == null
                                      ? slot.exerciseId
                                      : WorkoutCatalog.getExerciseById(
                                          log.performedExerciseId,
                                        ).name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: selected
                                        ? colors.onPrimary
                                        : colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Builder(
                  builder: (context) {
                    final index = _expandedIndex
                        .clamp(0, workoutDef.exercises.length - 1)
                        .toInt();
                    final slot = workoutDef.exercises[index];
                    final log = widget.state.exerciseLogs[slot.exerciseId];
                    if (log == null) return const SizedBox.shrink();
                    final performedExercise = WorkoutCatalog.getExerciseById(
                      log.performedExerciseId,
                    );
                    final previous = widget.state.previousLogs[slot.exerciseId];
                    return ExerciseCard(
                      log: log,
                      slot: slot,
                      displayUnit: log.displayUnit,
                      positionLabel:
                          'EXERCISE ${index + 1} OF ${workoutDef.exercises.length}',
                      previousDate: previous == null
                          ? null
                          : _friendlyDate(previous.dateKey),
                      previousSets: previous?.log.sets,
                      isExpanded: true,
                      onExpandToggle: () {},
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
                      onCopyPreviousSession: () => context
                          .read<WorkoutCubit>()
                          .copyPreviousSession(slot.exerciseId),
                      onAddSet: () =>
                          context.read<WorkoutCubit>().addSet(slot.exerciseId),
                      onRemoveSet: (setIndex) => context
                          .read<WorkoutCubit>()
                          .removeSet(slot.exerciseId, setIndex),
                    );
                  },
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _expandedIndex <= 0
                              ? null
                              : () => setState(() => _expandedIndex--),
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              _expandedIndex >= workoutDef.exercises.length - 1
                              ? null
                              : () => setState(() => _expandedIndex++),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                          label: const Text('Next exercise'),
                        ),
                      ),
                    ],
                  ),
                ),
                _UpNext(
                  state: widget.state,
                  slots: workoutDef.exercises,
                  current: _expandedIndex
                      .clamp(0, workoutDef.exercises.length - 1)
                      .toInt(),
                  onOpen: (i) => setState(() => _expandedIndex = i),
                ),
              ],
            ),
          ),
        ] else if (widget.state.workoutType != WorkoutType.rest &&
            (workoutDef == null || workoutDef.exercises.isEmpty))
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

/// "7 DAYS AGO" style label for a yyyy-MM-dd key.
String _friendlyDate(String dateKey) {
  final d = DateTime.tryParse(dateKey);
  if (d == null) return dateKey;
  final now = DateTime.now();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(d.year, d.month, d.day)).inDays;
  if (days <= 0) return 'TODAY';
  if (days == 1) return 'YESTERDAY';
  return '$days DAYS AGO';
}

/// The next exercises after the one in focus, with what you lifted last time.
class _UpNext extends StatelessWidget {
  final WorkoutState state;
  final List<ExerciseSlot> slots;
  final int current;
  final ValueChanged<int> onOpen;

  const _UpNext({
    required this.state,
    required this.slots,
    required this.current,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final next = [
      for (var i = current + 1; i < slots.length && i <= current + 3; i++) i,
    ];
    if (next.isEmpty) return const SizedBox.shrink();
    final left = slots.length - current - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Up next',
                style: ReportThemeTokens.outfitHeader(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$left LEFT',
                style: ReportThemeTokens.outfitSubtext(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurfaceVariant,
                ).copyWith(letterSpacing: 1.4),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final i in next) _row(context, i),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, int i) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slot = slots[i];
    final log = state.exerciseLogs[slot.exerciseId];
    final name = WorkoutCatalog.getExerciseById(
      log?.performedExerciseId ?? slot.exerciseId,
    ).name;
    final prev = state.previousLogs[slot.exerciseId]?.log.sets
        .where((s) => s.isPerformed && s.weightKg != null)
        .toList();
    final last = (prev == null || prev.isEmpty)
        ? null
        : prev.reduce((a, b) => (b.weightKg ?? 0) > (a.weightKg ?? 0) ? b : a);
    final unit = log?.displayUnit ?? state.displayUnit;
    final lastText = last == null
        ? ''
        : ' · Last ${formatWeight(last.weightKg!, unit)} ${unit.name} × ${last.actualReps ?? '–'}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? AppColors.borderSubtle : AppColors.outline,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onOpen(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkElevated
                        : const Color(0xFFF0F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: ReportThemeTokens.outfitNumber(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReportThemeTokens.outfitHeader(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        '${slot.prescribedSets} × ${slot.prescribedReps}$lastText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

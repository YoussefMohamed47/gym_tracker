import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';
import '../../domain/entities/workout_definition.dart';
import '../utils/video_launcher.dart';
import 'exercise_set_row.dart';

class ExerciseLogCard extends StatefulWidget {
  final ExerciseLog log;
  final ExerciseSlot slot;
  final WeightUnit displayUnit;
  final String? previousDate;
  final List<ExerciseSetLog>? previousSets;
  final Function(int setIndex, double? weight) onWeightChanged;
  final Function(int setIndex, int? reps) onRepsChanged;
  final Function(int setIndex) onToggleSetPerformed;
  final Function(WeightUnit unit) onUnitChanged;
  final VoidCallback onSelectAlternative;
  final VoidCallback onAddPhoto;
  final VoidCallback onShowHistory;
  final VoidCallback? onUseLegacyWeight;

  const ExerciseLogCard({
    super.key,
    required this.log,
    required this.slot,
    required this.displayUnit,
    this.previousDate,
    this.previousSets,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onToggleSetPerformed,
    required this.onUnitChanged,
    required this.onSelectAlternative,
    required this.onAddPhoto,
    required this.onShowHistory,
    this.onUseLegacyWeight,
  });

  @override
  State<ExerciseLogCard> createState() => _ExerciseLogCardState();
}

class _ExerciseLogCardState extends State<ExerciseLogCard> {
  late List<FocusNode> _weightFocusNodes;
  late List<FocusNode> _repsFocusNodes;

  @override
  void initState() {
    super.initState();
    _initFocusNodes();
  }

  void _initFocusNodes() {
    _weightFocusNodes = List.generate(
      widget.log.sets.length,
      (index) => FocusNode(),
    );
    _repsFocusNodes = List.generate(
      widget.log.sets.length,
      (index) => FocusNode(),
    );
  }

  @override
  void didUpdateWidget(ExerciseLogCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.log.sets.length != widget.log.sets.length) {
      for (final node in _weightFocusNodes) {
        node.dispose();
      }
      for (final node in _repsFocusNodes) {
        node.dispose();
      }
      _initFocusNodes();
    }
  }

  @override
  void dispose() {
    for (final node in _weightFocusNodes) {
      node.dispose();
    }
    for (final node in _repsFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final originalExercise = WorkoutCatalog.getExerciseById(
      widget.log.plannedExerciseId,
    );
    final performedExercise = WorkoutCatalog.getExerciseById(
      widget.log.performedExerciseId,
    );
    final isAlternative =
        widget.log.plannedExerciseId != widget.log.performedExerciseId;

    final isFullyPerformed = widget.log.sets.isNotEmpty &&
        widget.log.sets.every((s) => s.isPerformed);

    final hasAnyPerformed = widget.log.sets.any((s) => s.isPerformed);

    // Check if it's a duration-based exercise
    final isDurationBased = widget.slot.prescribedReps.contains('s');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isFullyPerformed
            ? AppColors.success.withValues(alpha: 0.05)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFullyPerformed
              ? AppColors.success.withValues(alpha: 0.5)
              : hasAnyPerformed
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAlternative)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Planned: ${originalExercise.name}'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      Text(
                        performedExercise.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color:
                                  isFullyPerformed ? AppColors.success : null,
                            ),
                      ),
                    ],
                  ),
                ),
                if (performedExercise.videoUrl != null)
                  IconButton(
                    icon: Icon(
                      Icons.play_circle_filled_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    onPressed: () => VideoLauncher.launch(
                      context,
                      performedExercise.videoUrl!,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),
            // Prescription Info
            Row(
              children: [
                Icon(Icons.repeat_rounded,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  '${widget.slot.prescribedSets} sets • ${widget.slot.prescribedReps} • Rest ${widget.slot.prescribedRest}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                _UnitSwitcher(
                  unit: widget.log.displayUnit,
                  onChanged: widget.onUnitChanged,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Previous Info
            if (widget.previousDate != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PREVIOUS • ${widget.previousDate}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

            // Legacy Action
            if (widget.log.weightKg != null && widget.log.sets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: widget.onUseLegacyWeight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Legacy ref: ${WeightConverter.format(WeightConverter.convert(widget.log.weightKg!, WeightUnit.kg, widget.displayUnit))} ${widget.displayUnit.name}. Use for all sets?',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Set Table Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 32,
                    child: Text(
                      'SET',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'LAST',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'WEIGHT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 48,
                    child: Text(
                      'DONE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Set Rows
            ...List.generate(widget.log.sets.length, (index) {
              return ExerciseSetRow(
                index: index,
                setLog: widget.log.sets[index],
                previousSetLog: (widget.previousSets != null &&
                        widget.previousSets!.length > index)
                    ? widget.previousSets![index]
                    : null,
                displayUnit: widget.log.displayUnit,
                isRepsAllowed: !isDurationBased,
                onWeightChanged: (w) => widget.onWeightChanged(index, w),
                onRepsChanged: (r) => widget.onRepsChanged(index, r),
                onTogglePerformed: () => widget.onToggleSetPerformed(index),
                weightFocusNode: _weightFocusNodes[index],
                repsFocusNode: _repsFocusNodes[index],
                onWeightSubmitted: () {
                  if (!isDurationBased) {
                    _repsFocusNodes[index].requestFocus();
                  } else if (index < widget.log.sets.length - 1) {
                    _weightFocusNodes[index + 1].requestFocus();
                  }
                },
                onRepsSubmitted: () {
                  if (index < widget.log.sets.length - 1) {
                    _weightFocusNodes[index + 1].requestFocus();
                  }
                },
              );
            }),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1),
            ),

            // Action Buttons
            Row(
              children: [
                _CompactActionButton(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onPressed: widget.onShowHistory,
                ),
                const SizedBox(width: 10),
                _CompactActionButton(
                  icon: widget.log.imagePath != null
                      ? Icons.image_rounded
                      : Icons.add_a_photo_rounded,
                  label: 'Photo',
                  onPressed: widget.onAddPhoto,
                  active: widget.log.imagePath != null,
                ),
                const SizedBox(width: 10),
                _CompactActionButton(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Alt',
                  onPressed: widget.onSelectAlternative,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitSwitcher extends StatelessWidget {
  final WeightUnit unit;
  final Function(WeightUnit) onChanged;

  const _UnitSwitcher({required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: WeightUnit.values.map((u) {
          final isSelected = u == unit;
          return GestureDetector(
            onTap: () => onChanged(u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                u.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
            color: active ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : Theme.of(context).cardTheme.color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

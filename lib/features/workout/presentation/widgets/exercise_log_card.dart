import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';
import '../../domain/entities/workout_definition.dart';
import 'package:url_launcher/url_launcher.dart';
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

    // Check if it's a duration-based exercise
    final isDurationBased = widget.slot.prescribedReps.contains('s');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAlternative)
                        Text(
                          'Planned: ${originalExercise.name}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      Text(
                        performedExercise.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _UnitSwitcher(
                  unit: widget.log.displayUnit,
                  onChanged: widget.onUnitChanged,
                ),
                if (performedExercise.videoUrl != null)
                  IconButton(
                    icon: const Icon(
                      Icons.play_circle_outline,
                      color: AppColors.primaryBlue,
                    ),
                    onPressed: () => VideoLauncher.launch(
                      context,
                      performedExercise.videoUrl!,
                    ),
                  ),
              ],
            ),

            // Prescription Info
            Text(
              '${widget.slot.prescribedSets} sets • ${widget.slot.prescribedReps} • Rest ${widget.slot.prescribedRest}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),

            // Previous Info
            if (widget.previousDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Previous • ${widget.previousDate}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ),

            // Legacy Action
            if (widget.log.weightKg != null && widget.log.sets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: widget.onUseLegacyWeight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: Colors.amber.shade900,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Legacy ref: ${WeightConverter.format(WeightConverter.convert(widget.log.weightKg!, WeightUnit.kg, widget.displayUnit))} ${widget.displayUnit.name}. Use for all sets?',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Set Table Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 32,
                    child: Text(
                      'SET',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
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
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
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
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
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
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
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
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
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
                previousSetLog:
                    (widget.previousSets != null &&
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

            const Divider(height: 24),

            // Action Buttons
            Row(
              children: [
                _CompactActionButton(
                  icon: Icons.history,
                  label: 'History',
                  onPressed: widget.onShowHistory,
                ),
                const SizedBox(width: 8),
                _CompactActionButton(
                  icon: widget.log.imagePath != null
                      ? Icons.image
                      : Icons.add_a_photo_outlined,
                  label: 'Photo',
                  onPressed: widget.onAddPhoto,
                  active: widget.log.imagePath != null,
                ),
                const SizedBox(width: 8),
                _CompactActionButton(
                  icon: Icons.swap_horiz,
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
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: WeightUnit.values.map((u) {
          final isSelected = u == unit;
          return GestureDetector(
            onTap: () => onChanged(u),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                u.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: active ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: active ? AppColors.primaryBlue.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppColors.primaryBlue : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? AppColors.primaryBlue : Colors.grey.shade700,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

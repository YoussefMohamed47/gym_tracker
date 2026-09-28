import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_set_log.dart';

class ExerciseSetRow extends StatefulWidget {
  final int index;
  final ExerciseSetLog setLog;
  final ExerciseSetLog? previousSetLog;
  final WeightUnit displayUnit;
  final bool isWeightAllowed;
  final bool isRepsAllowed;
  final Function(double? weight) onWeightChanged;
  final Function(int? reps) onRepsChanged;
  final Function(double delta)? onStepWeight;
  final Function(int delta)? onStepReps;
  final VoidCallback onTogglePerformed;
  final VoidCallback? onDeleteSet;
  final FocusNode? weightFocusNode;
  final FocusNode? repsFocusNode;
  final VoidCallback? onWeightSubmitted;
  final VoidCallback? onRepsSubmitted;

  const ExerciseSetRow({
    super.key,
    required this.index,
    required this.setLog,
    this.previousSetLog,
    required this.displayUnit,
    this.isWeightAllowed = true,
    this.isRepsAllowed = true,
    required this.onWeightChanged,
    required this.onRepsChanged,
    this.onStepWeight,
    this.onStepReps,
    required this.onTogglePerformed,
    this.onDeleteSet,
    this.weightFocusNode,
    this.repsFocusNode,
    this.onWeightSubmitted,
    this.onRepsSubmitted,
  });

  @override
  State<ExerciseSetRow> createState() => _ExerciseSetRowState();
}

class _ExerciseSetRowState extends State<ExerciseSetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  String? _repsError;

  @override
  void initState() {
    super.initState();
    final weight = widget.setLog.weightKg != null
        ? WeightConverter.convert(
            widget.setLog.weightKg!,
            WeightUnit.kg,
            widget.displayUnit,
          )
        : null;
    _weightController = TextEditingController(
      text: weight != null
          ? weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)
          : '',
    );
    _repsController = TextEditingController(
      text: widget.setLog.actualReps?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(ExerciseSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync Weight
    if (oldWidget.setLog.weightKg != widget.setLog.weightKg ||
        oldWidget.displayUnit != widget.displayUnit) {
      final weight = widget.setLog.weightKg != null
          ? WeightConverter.convert(
              widget.setLog.weightKg!,
              WeightUnit.kg,
              widget.displayUnit,
            )
          : null;
      final newText = weight != null
          ? weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)
          : '';
      if (_weightController.text != newText &&
          !(widget.weightFocusNode?.hasFocus ?? false)) {
        _weightController.text = newText;
      }
    }
    // Sync Reps
    if (oldWidget.setLog.actualReps != widget.setLog.actualReps) {
      final newText = widget.setLog.actualReps?.toString() ?? '';
      if (_repsController.text != newText &&
          !(widget.repsFocusNode?.hasFocus ?? false)) {
        _repsController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _validateReps(String value) {
    if (value.isEmpty) {
      setState(() => _repsError = null);
      widget.onRepsChanged(null);
      return;
    }

    final reps = int.tryParse(value);
    if (reps == null || reps <= 0) {
      setState(() => _repsError = 'Reps must be greater than 0');
    } else {
      setState(() => _repsError = null);
      widget.onRepsChanged(reps);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final lastWeight = widget.previousSetLog?.weightKg != null
        ? WeightConverter.convert(
            widget.previousSetLog!.weightKg!,
            WeightUnit.kg,
            widget.displayUnit,
          )
        : null;
    final lastReps = widget.previousSetLog?.actualReps;

    String lastLabel = '—';
    if (lastWeight != null || lastReps != null) {
      final w = lastWeight != null
          ? lastWeight.toStringAsFixed(lastWeight % 1 == 0 ? 0 : 1)
          : '';
      final r = lastReps != null ? '×$lastReps' : '';
      lastLabel = '$w$r'.trim();
      if (lastWeight != null) lastLabel += ' ${widget.displayUnit.name}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              // Set Number
              SizedBox(
                width: 22,
                child: Text(
                  '${widget.index + 1}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // Last Value
              Expanded(
                flex: 2,
                child: Text(
                  lastLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Weight Input with Stepper Controls
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: widget.isWeightAllowed
                      ? Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => widget.onStepWeight?.call(-2.5),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 6,
                                  ),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 13,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _weightController,
                                  focusNode: widget.weightFocusNode,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textInputAction: TextInputAction.next,
                                  textAlign: TextAlign.center,
                                  onSubmitted: (_) =>
                                      widget.onWeightSubmitted?.call(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 0,
                                    ),
                                    border: InputBorder.none,
                                    hintText: '0',
                                    suffixText: widget.displayUnit.name,
                                    suffixStyle: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (value) {
                                    final weight = double.tryParse(value);
                                    widget.onWeightChanged(weight);
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: () => widget.onStepWeight?.call(2.5),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 6,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 13,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(child: Text('—')),
                ),
              ),

              // Reps Input with Stepper Controls
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: widget.isRepsAllowed
                      ? Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => widget.onStepReps?.call(-1),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 6,
                                  ),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 13,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _repsController,
                                  focusNode: widget.repsFocusNode,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  textAlign: TextAlign.center,
                                  onSubmitted: (_) =>
                                      widget.onRepsSubmitted?.call(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 0,
                                    ),
                                    border: InputBorder.none,
                                    hintText: '0',
                                    suffixText: 'r',
                                    suffixStyle: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: _validateReps,
                                ),
                              ),
                              InkWell(
                                onTap: () => widget.onStepReps?.call(1),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 6,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 13,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(child: Text('—')),
                ),
              ),

              // Done Toggle
              SizedBox(
                width: 32,
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      widget.setLog.isPerformed
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: widget.setLog.isPerformed
                          ? colorScheme.primary
                          : colorScheme.outline,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onTogglePerformed,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_repsError != null)
          Padding(
            padding: const EdgeInsets.only(left: 22, bottom: 4),
            child: Text(
              _repsError!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}

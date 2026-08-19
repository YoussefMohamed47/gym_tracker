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
  final VoidCallback onTogglePerformed;
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
    required this.onTogglePerformed,
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
      // Do not persist invalid value
    } else {
      setState(() => _repsError = null);
      widget.onRepsChanged(reps);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      final r = lastReps != null ? '× $lastReps' : '';
      lastLabel = '$w$r'.trim();
      if (lastWeight != null) lastLabel += ' ${widget.displayUnit.name}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Set Number
              SizedBox(
                width: 32,
                child: Text(
                  '${widget.index + 1}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              // Last Value
              Expanded(
                flex: 3,
                child: Text(
                  lastLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),

              // Weight Input
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: widget.isWeightAllowed
                      ? TextField(
                          controller: _weightController,
                          focusNode: widget.weightFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => widget.onWeightSubmitted?.call(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '0',
                            suffixText: widget.displayUnit.name,
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: (value) {
                            final weight = double.tryParse(value);
                            widget.onWeightChanged(weight);
                          },
                        )
                      : const Center(child: Text('—')),
                ),
              ),

              // Reps Input
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: widget.isRepsAllowed
                      ? TextField(
                          controller: _repsController,
                          focusNode: widget.repsFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => widget.onRepsSubmitted?.call(),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '0',
                            suffixText: 'r',
                            errorText: null, // Error shown below row
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: _validateReps,
                        )
                      : const Center(child: Text('—')),
                ),
              ),

              // Done Toggle
              SizedBox(
                width: 48,
                child: IconButton(
                  icon: Icon(
                    widget.setLog.isPerformed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: widget.setLog.isPerformed
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  onPressed: widget.onTogglePerformed,
                ),
              ),
            ],
          ),
        ),
        if (_repsError != null)
          Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 4),
            child: Text(
              _repsError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}

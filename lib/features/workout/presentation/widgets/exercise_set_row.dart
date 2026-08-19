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
  final Function(double? weight) onWeightChanged;
  final VoidCallback onTogglePerformed;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onFieldSubmitted;

  const ExerciseSetRow({
    super.key,
    required this.index,
    required this.setLog,
    this.previousSetLog,
    required this.displayUnit,
    this.isWeightAllowed = true,
    required this.onWeightChanged,
    required this.onTogglePerformed,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  State<ExerciseSetRow> createState() => _ExerciseSetRowState();
}

class _ExerciseSetRowState extends State<ExerciseSetRow> {
  late TextEditingController _controller;

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
    _controller = TextEditingController(
      text: weight != null
          ? weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)
          : '',
    );
  }

  @override
  void didUpdateWidget(ExerciseSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
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
      if (_controller.text != newText && !widget.focusNode!.hasFocus) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 40,
            child: Text(
              '${widget.index + 1}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // Last Weight
          Expanded(
            flex: 2,
            child: Text(
              lastWeight != null
                  ? '${lastWeight.toStringAsFixed(lastWeight % 1 == 0 ? 0 : 1)} ${widget.displayUnit.name}'
                  : '—',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ),

          // Today Weight Input
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: widget.isWeightAllowed
                  ? TextField(
                      controller: _controller,
                      focusNode: widget.focusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: widget.textInputAction,
                      onSubmitted: (_) => widget.onFieldSubmitted?.call(),
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
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) {
                        final weight = double.tryParse(value);
                        widget.onWeightChanged(weight);
                      },
                    )
                  : const Center(child: Text('—')),
            ),
          ),

          // Done Toggle
          SizedBox(
            width: 60,
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
    );
  }
}

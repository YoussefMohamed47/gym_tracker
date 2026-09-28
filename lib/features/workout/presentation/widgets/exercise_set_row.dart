import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_set_log.dart';
import 'numeric_keypad_sheet.dart';

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
  final String exerciseName;

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
    this.exerciseName = '',
  });

  @override
  State<ExerciseSetRow> createState() => _ExerciseSetRowState();
}

class _ExerciseSetRowState extends State<ExerciseSetRow>
    with SingleTickerProviderStateMixin {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  Timer? _autoRepeatTimer;
  late AnimationController _checkAnimationController;
  late Animation<double> _checkScaleAnimation;

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
          ? (weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1))
          : '',
    );
    _repsController = TextEditingController(
      text: widget.setLog.actualReps?.toString() ?? '',
    );

    _checkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.setLog.isPerformed) {
      _checkAnimationController.value = 1.0;
    }
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
          ? (weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1))
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

    if (!oldWidget.setLog.isPerformed && widget.setLog.isPerformed) {
      _checkAnimationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _autoRepeatTimer?.cancel();
    _checkAnimationController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _startAutoRepeat(VoidCallback action) {
    action();
    _autoRepeatTimer?.cancel();
    _autoRepeatTimer = Timer.periodic(
      const Duration(milliseconds: 120),
      (_) => action(),
    );
  }

  void _stopAutoRepeat() {
    _autoRepeatTimer?.cancel();
  }

  Future<void> _openWeightKeypad() async {
    final currentWeight = widget.setLog.weightKg != null
        ? WeightConverter.convert(
            widget.setLog.weightKg!,
            WeightUnit.kg,
            widget.displayUnit,
          )
        : null;

    final result = await NumericKeypadSheet.showWeightKeypad(
      context,
      title: '${widget.exerciseName} - Set ${widget.index + 1} Weight',
      initialValue: currentWeight,
      unit: widget.displayUnit.name.toUpperCase(),
    );

    if (result != null) {
      widget.onWeightChanged(result);
    }
  }

  Future<void> _openRepsKeypad() async {
    final result = await NumericKeypadSheet.showRepsKeypad(
      context,
      title: '${widget.exerciseName} - Set ${widget.index + 1} Reps',
      initialValue: widget.setLog.actualReps,
    );

    if (result != null) {
      widget.onRepsChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPerformed = widget.setLog.isPerformed;

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
          ? (lastWeight % 1 == 0 ? lastWeight.toInt().toString() : lastWeight.toStringAsFixed(1))
          : '';
      final r = lastReps != null ? '×$lastReps' : '';
      lastLabel = '$w$r'.trim();
      if (lastWeight != null) lastLabel += ' ${widget.displayUnit.name}';
    }

    final rowContent = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: isPerformed
            ? AppColors.completedGreen.withValues(alpha: isDark ? 0.12 : 0.08)
            : (isDark ? AppColors.darkElevated.withValues(alpha: 0.5) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPerformed
              ? AppColors.completedGreen.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderSubtle : AppColors.outline),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 28,
            child: Text(
              '${widget.index + 1}',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isPerformed ? AppColors.completedGreen : theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Last Value Ghosted
          Expanded(
            flex: 2,
            child: Text(
              lastLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Weight Field with Large Buttons & Keypad Tap
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: widget.isWeightAllowed
                  ? Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPerformed
                              ? AppColors.completedGreen.withValues(alpha: 0.3)
                              : (isDark ? AppColors.borderSubtle : AppColors.outline),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTapDown: (_) => _startAutoRepeat(() {
                              HapticFeedback.lightImpact();
                              widget.onStepWeight?.call(-2.5);
                            }),
                            onTapUp: (_) => _stopAutoRepeat(),
                            onTapCancel: _stopAutoRepeat,
                            child: Container(
                              width: 32,
                              height: double.infinity,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(11),
                                ),
                              ),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 16,
                                color: isPerformed
                                    ? AppColors.completedGreen
                                    : AppColors.gradientStart,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _openWeightKeypad,
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _weightController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    border: InputBorder.none,
                                    hintText: '0',
                                    suffixText: widget.displayUnit.name,
                                    suffixStyle: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                    color: isPerformed
                                        ? AppColors.completedGreen
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTapDown: (_) => _startAutoRepeat(() {
                              HapticFeedback.lightImpact();
                              widget.onStepWeight?.call(2.5);
                            }),
                            onTapUp: (_) => _stopAutoRepeat(),
                            onTapCancel: _stopAutoRepeat,
                            child: Container(
                              width: 32,
                              height: double.infinity,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(11),
                                ),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: isPerformed
                                    ? AppColors.completedGreen
                                    : AppColors.gradientStart,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text('—')),
            ),
          ),

          // Reps Field with Large Buttons & Keypad Tap
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: widget.isRepsAllowed
                  ? Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPerformed
                              ? AppColors.completedGreen.withValues(alpha: 0.3)
                              : (isDark ? AppColors.borderSubtle : AppColors.outline),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTapDown: (_) => _startAutoRepeat(() {
                              HapticFeedback.lightImpact();
                              widget.onStepReps?.call(-1);
                            }),
                            onTapUp: (_) => _stopAutoRepeat(),
                            onTapCancel: _stopAutoRepeat,
                            child: Container(
                              width: 32,
                              height: double.infinity,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(11),
                                ),
                              ),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 16,
                                color: isPerformed
                                    ? AppColors.completedGreen
                                    : AppColors.gradientStart,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _openRepsKeypad,
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _repsController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    border: InputBorder.none,
                                    hintText: '0',
                                    suffixText: 'r',
                                    suffixStyle: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                    color: isPerformed
                                        ? AppColors.completedGreen
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTapDown: (_) => _startAutoRepeat(() {
                              HapticFeedback.lightImpact();
                              widget.onStepReps?.call(1);
                            }),
                            onTapUp: (_) => _stopAutoRepeat(),
                            onTapCancel: _stopAutoRepeat,
                            child: Container(
                              width: 32,
                              height: double.infinity,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(11),
                                ),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: isPerformed
                                    ? AppColors.completedGreen
                                    : AppColors.gradientStart,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text('—')),
            ),
          ),

          // Large Done Checkbox with Bounce Animation
          SizedBox(
            width: 44,
            height: 42,
            child: Center(
              child: ScaleTransition(
                scale: _checkScaleAnimation,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onTogglePerformed();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isPerformed
                          ? AppColors.completedGreen
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPerformed
                            ? AppColors.completedGreen
                            : (isDark
                                ? Colors.white30
                                : Colors.black26),
                        width: 2,
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
                    child: isPerformed
                        ? const Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: Colors.black,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.onDeleteSet != null) {
      return Dismissible(
        key: ValueKey('set_${widget.index}_${widget.setLog.hashCode}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          HapticFeedback.mediumImpact();
          widget.onDeleteSet?.call();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.destructiveRed.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.destructiveRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.delete_outline_rounded,
                color: AppColors.destructiveRed,
                size: 20,
              ),
            ],
          ),
        ),
        child: rowContent,
      );
    }

    return rowContent;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_set_log.dart';
import 'number_stepper.dart';

class SetRow extends StatelessWidget {
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
  final VoidCallback? onTapWeight;
  final VoidCallback? onTapReps;

  /// The next set to do: outlined in the accent colour.
  final bool isActive;

  /// This set beat last time's best weight: highlighted in amber.
  final bool isPersonalRecord;

  /// Has numbers but isn't ticked, while a later set is: probably forgotten.
  /// The tick box turns amber so it doesn't go uncounted.
  final bool needsTick;

  const SetRow({
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
    this.onTapWeight,
    this.onTapReps,
    this.isActive = false,
    this.isPersonalRecord = false,
    this.needsTick = false,
  });

  String _formatWeight(double? weightKg) {
    if (weightKg == null) return '';
    final converted = WeightConverter.convert(
      weightKg,
      WeightUnit.kg,
      displayUnit,
    );
    return converted % 1 == 0
        ? converted.toInt().toString()
        : converted.toStringAsFixed(1);
  }

  /// Last time's set, compact enough for the narrow column: "60×10" or
  /// "×12". A weight with no reps keeps its unit ("60kg") so it can't be
  /// read as a rep count.
  String _formatPrevious() {
    final prev = previousSetLog;
    if (prev == null) return '—';
    final hasWeight = isWeightAllowed && prev.weightKg != null;
    final hasReps = isRepsAllowed && prev.actualReps != null;
    final weight = hasWeight ? _formatWeight(prev.weightKg) : '';
    if (hasWeight && !hasReps) return '$weight${displayUnit.name}';
    final text = '$weight${hasReps ? '×${prev.actualReps}' : ''}';
    return text.isEmpty ? '—' : text;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = setLog.isPerformed;
    final weightStr = _formatWeight(setLog.weightKg);
    final repsStr = setLog.actualReps?.toString() ?? '';

    final row = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 3),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isPersonalRecord
            ? AppColors.restAmber.withValues(alpha: 0.14)
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPersonalRecord
              ? AppColors.restAmber.withValues(alpha: 0.55)
              : isCompleted
              ? AppColors.completedGreen.withValues(alpha: 0.35)
              : isActive
              ? Theme.of(context).colorScheme.primary
              : (isDark ? AppColors.borderSubtle : AppColors.outline),
          width: isActive && !isCompleted ? 1.5 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Ticking a set sweeps a green fill across the row, left to right.
          Positioned.fill(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AnimatedFractionallySizedBox(
                duration: context.motion(const Duration(milliseconds: 320)),
                curve: Curves.easeOutCubic,
                widthFactor: isCompleted && !isPersonalRecord ? 1 : 0,
                heightFactor: 1,
                child: ColoredBox(
                  color: AppColors.completedGreen.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Set Number + Ghosted Previous
                SizedBox(
                  width: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${index + 1}',
                        style: ReportThemeTokens.outfitHeader(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isCompleted
                              ? AppColors.completedGreen
                              : (isDark
                                    ? AppColors.textPrimary
                                    : Colors.black87),
                        ),
                      ),
                      Text(
                        _formatPrevious(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),

                // Weight Stepper
                if (isWeightAllowed) ...[
                  Expanded(
                    flex: 1,
                    child: NumberStepper(
                      label: 'WEIGHT',
                      valueText: weightStr,
                      unit: displayUnit.name,
                      onIncrement: () {
                        if (onStepWeight != null) {
                          onStepWeight!(
                            displayUnit == WeightUnit.kg ? 2.5 : 5.0,
                          );
                        } else {
                          final cur = setLog.weightKg ?? 0.0;
                          onWeightChanged(
                            cur + (displayUnit == WeightUnit.kg ? 2.5 : 2.268),
                          );
                        }
                      },
                      onDecrement: () {
                        if (onStepWeight != null) {
                          onStepWeight!(
                            displayUnit == WeightUnit.kg ? -2.5 : -5.0,
                          );
                        } else {
                          final cur = setLog.weightKg ?? 0.0;
                          final step = displayUnit == WeightUnit.kg
                              ? 2.5
                              : 2.268;
                          onWeightChanged((cur - step) < 0 ? 0.0 : cur - step);
                        }
                      },
                      onTapValue: onTapWeight,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Reps Stepper
                if (isRepsAllowed) ...[
                  Expanded(
                    flex: 1,
                    child: NumberStepper(
                      label: 'REPS',
                      valueText: repsStr,
                      unit: 'r',
                      onIncrement: () {
                        if (onStepReps != null) {
                          onStepReps!(1);
                        } else {
                          final cur = setLog.actualReps ?? 0;
                          onRepsChanged(cur + 1);
                        }
                      },
                      onDecrement: () {
                        if (onStepReps != null) {
                          onStepReps!(-1);
                        } else {
                          final cur = setLog.actualReps ?? 0;
                          onRepsChanged((cur - 1) < 0 ? 0 : cur - 1);
                        }
                      },
                      onTapValue: onTapReps,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Done Checkbox (RepaintBoundary isolated)
                RepaintBoundary(
                  child: Semantics(
                    hint: needsTick
                        ? 'Not counted yet. Tap to count this set'
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onTogglePerformed();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.completedGreen
                              : needsTick
                              ? AppColors.restAmber.withValues(alpha: 0.18)
                              : (isDark
                                    ? AppColors.darkElevated
                                    : AppColors.lightElevated),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.completedGreen
                                : needsTick
                                ? AppColors.restAmber
                                : (isDark
                                      ? AppColors.borderSubtle
                                      : AppColors.outline),
                            width: needsTick ? 2 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    key: ValueKey('check'),
                                    color: Colors.black,
                                    size: 20,
                                  )
                                : Icon(
                                    Icons.check_rounded,
                                    key: const ValueKey('uncheck'),
                                    color: needsTick
                                        ? AppColors.restAmber
                                        : (isDark
                                              ? Colors.white24
                                              : Colors.black26),
                                    size: 16,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Delete set option (if provided)
                if (onDeleteSet != null) ...[
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onDeleteSet!();
                    },
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 40,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // The next set to do gives a small pop when it becomes the next one. The
    // wrapper is always there, so the row (and its steppers) is never rebuilt
    // from scratch when it becomes active.
    return _PopWhenActive(active: isActive && !isCompleted, child: row);
  }
}

class _PopWhenActive extends StatefulWidget {
  final bool active;
  final Widget child;
  const _PopWhenActive({required this.active, required this.child});

  @override
  State<_PopWhenActive> createState() => _PopWhenActiveState();
}

class _PopWhenActiveState extends State<_PopWhenActive>
    with SingleTickerProviderStateMixin {
  // Starts finished (full size); only plays when the row becomes active.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 1,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.96,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void didUpdateWidget(_PopWhenActive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.duration = context.motion(const Duration(milliseconds: 280));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}

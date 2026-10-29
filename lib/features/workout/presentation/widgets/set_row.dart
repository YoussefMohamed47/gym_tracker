import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/report_theme_tokens.dart';
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
  });

  String _formatWeight(double? weightKg) {
    if (weightKg == null) return '';
    final converted = WeightConverter.convert(weightKg, WeightUnit.kg, displayUnit);
    return converted % 1 == 0 ? converted.toInt().toString() : converted.toStringAsFixed(1);
  }

  String _formatPrevious() {
    if (previousSetLog == null) return '—';
    final parts = <String>[];
    if (isWeightAllowed && previousSetLog!.weightKg != null) {
      parts.add('${_formatWeight(previousSetLog!.weightKg)} ${displayUnit.name}');
    }
    if (isRepsAllowed && previousSetLog!.actualReps != null) {
      parts.add('${previousSetLog!.actualReps}r');
    }
    return parts.isEmpty ? '—' : parts.join(' × ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = setLog.isPerformed;
    final weightStr = _formatWeight(setLog.weightKg);
    final repsStr = setLog.actualReps?.toString() ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.completedGreen.withValues(alpha: 0.08)
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.completedGreen.withValues(alpha: 0.35)
              : (isDark ? AppColors.borderSubtle : AppColors.outline),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Set Number + Ghosted Previous
          SizedBox(
            width: 44,
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
                        : (isDark ? AppColors.textPrimary : Colors.black87),
                  ),
                ),
                Text(
                  _formatPrevious(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ReportThemeTokens.outfitSubtext(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Weight Stepper
          if (isWeightAllowed) ...[
            Expanded(
              flex: 5,
              child: NumberStepper(
                label: 'WEIGHT',
                valueText: weightStr,
                unit: displayUnit.name,
                onIncrement: () {
                  if (onStepWeight != null) {
                    onStepWeight!(displayUnit == WeightUnit.kg ? 2.5 : 5.0);
                  } else {
                    final cur = setLog.weightKg ?? 0.0;
                    onWeightChanged(cur + (displayUnit == WeightUnit.kg ? 2.5 : 2.268));
                  }
                },
                onDecrement: () {
                  if (onStepWeight != null) {
                    onStepWeight!(displayUnit == WeightUnit.kg ? -2.5 : -5.0);
                  } else {
                    final cur = setLog.weightKg ?? 0.0;
                    final step = displayUnit == WeightUnit.kg ? 2.5 : 2.268;
                    onWeightChanged((cur - step) < 0 ? 0.0 : cur - step);
                  }
                },
                onTapValue: onTapWeight,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Reps Stepper
          if (isRepsAllowed) ...[
            Expanded(
              flex: 4,
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
            const SizedBox(width: 8),
          ],

          // Done Checkbox (RepaintBoundary isolated)
          RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onTogglePerformed();
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.completedGreen
                      : (isDark ? AppColors.darkElevated : const Color(0xFFE8EBF2)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.completedGreen
                        : (isDark ? AppColors.borderSubtle : AppColors.outline),
                    width: 1.5,
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
                            size: 22,
                          )
                        : Icon(
                            Icons.check_rounded,
                            key: const ValueKey('uncheck'),
                            color: isDark ? Colors.white24 : Colors.black26,
                            size: 18,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // Delete set option (if provided)
          if (onDeleteSet != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                onDeleteSet!();
              },
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 48),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../cubit/workout_cubit.dart';

/// A large tick-off button for one warm-up or routine set ("S1" → ✓).
/// At least 48 px tall so it is easy to hit mid-workout.
class SetCheckButton extends StatelessWidget {
  final String exerciseId;
  final int setIndex;
  final bool isPerformed;

  const SetCheckButton({
    super.key,
    required this.exerciseId,
    required this.setIndex,
    required this.isPerformed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void toggle() {
      HapticFeedback.mediumImpact();
      context.read<WorkoutCubit>().toggleSetPerformed(exerciseId, setIndex);
    }

    return RepaintBoundary(
      // One node for screen readers: "Set 1, button, checked", tappable.
      child: Semantics(
        button: true,
        checked: isPerformed,
        label: 'Set ${setIndex + 1}',
        onTap: toggle,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 48,
            decoration: BoxDecoration(
              color: isPerformed
                  ? AppColors.completedGreen
                  : (isDark ? AppColors.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPerformed
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
                child: isPerformed
                    ? const Icon(
                        Icons.check_rounded,
                        key: ValueKey('done'),
                        size: 20,
                        color: Colors.black,
                      )
                    : Text(
                        'S${setIndex + 1}',
                        key: const ValueKey('undone'),
                        style: ReportThemeTokens.outfitNumber(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimary
                              : Colors.black87,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

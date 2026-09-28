import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/theme_transition_controller.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../settings/presentation/cubit/theme_cubit.dart';
import '../cubit/workout_state.dart';
import 'workout_switcher_sheet.dart';

class WorkoutHeader extends StatefulWidget {
  final WorkoutState state;
  final VoidCallback onTypeTapped;

  const WorkoutHeader({
    super.key,
    required this.state,
    required this.onTypeTapped,
  });

  @override
  State<WorkoutHeader> createState() => _WorkoutHeaderState();
}

class _WorkoutHeaderState extends State<WorkoutHeader> {
  final GlobalKey _themeButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    int performedCount = 0;
    int totalCount = 0;

    for (final log in widget.state.exerciseLogs.values) {
      totalCount += log.sets.length;
      performedCount += log.sets.where((s) => s.isPerformed).length;
    }

    final double progress = totalCount > 0 ? (performedCount / totalCount) : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Animated Live Progress Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 5,
                          backgroundColor: isDark
                              ? AppColors.borderSubtle
                              : Colors.black12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gradientStart,
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: AppColors.gradientStart,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Title & Tappable Workout Chip
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        WorkoutSwitcherSheet.show(context);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gradientStart.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.gradientStart.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.state.workoutType.displayName.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.gradientStart,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.gradientStart,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Training Session',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Theme Toggle Button
              IconButton.filledTonal(
                key: _themeButtonKey,
                onPressed: () {
                  di.sl<ThemeTransitionController>().animateThemeToggle(
                        context: context,
                        buttonKey: _themeButtonKey,
                        onToggle: () => context.read<ThemeCubit>().toggleTheme(),
                      );
                },
                icon: Icon(
                  isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkElevated
                      : Colors.grey.shade200,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

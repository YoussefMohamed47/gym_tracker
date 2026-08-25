import 'package:flutter/material.dart';
import '../../../settings/presentation/cubit/theme_cubit.dart';
import '../cubit/workout_state.dart';
import 'workout_week_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/workout_cubit.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/theme_transition_controller.dart';

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
    final performedCount = widget.state.exerciseLogs.values
        .where((log) => log.sets.any((s) => s.isPerformed))
        .length;
    final totalCount = widget.state.exerciseLogs.length;
    final progress = totalCount > 0 ? performedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Progress Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: widget.onTypeTapped,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.state.workoutType.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Training Session',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),
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
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          WorkoutWeekHeader(
            selectedDate: widget.state.selectedDate,
            onPreviousWeek: () => context.read<WorkoutCubit>().navigateWeek(-1),
            onNextWeek: () => context.read<WorkoutCubit>().navigateWeek(1),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

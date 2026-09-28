import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';

class WorkoutStickySaveBar extends StatelessWidget {
  final WorkoutState state;

  const WorkoutStickySaveBar({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.workoutType == WorkoutType.rest ||
        state.status == WorkoutStatus.loading) {
      return const SizedBox.shrink();
    }

    final performedCount = state.exerciseLogs.values
        .where((log) => log.sets.any((s) => s.isPerformed))
        .length;
    final totalCount = state.exerciseLogs.length;

    int totalSets = 0;
    int performedSets = 0;
    for (final log in state.exerciseLogs.values) {
      totalSets += log.sets.length;
      performedSets += log.sets.where((s) => s.isPerformed).length;
    }

    final percent = totalCount > 0 ? ((performedCount / totalCount) * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$performedCount OF $totalCount EXERCISES',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$performedSets/$totalSets SETS ($percent%)',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? performedCount / totalCount : 0,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ElevatedButton(
            onPressed: state.status == WorkoutStatus.saving
                ? null
                : () => context.read<WorkoutCubit>().saveWorkout(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: state.status == WorkoutStatus.saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'FINISH WORKOUT',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

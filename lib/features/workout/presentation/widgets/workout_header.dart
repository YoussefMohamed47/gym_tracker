import 'package:flutter/material.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_state.dart';
import 'workout_week_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/workout_cubit.dart';

class WorkoutHeader extends StatelessWidget {
  final WorkoutState state;
  final VoidCallback onTypeTapped;

  const WorkoutHeader({
    super.key,
    required this.state,
    required this.onTypeTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onTypeTapped,
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.workoutType.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.swap_horiz,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Weekly Workout',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          WorkoutWeekHeader(
            selectedDate: state.selectedDate,
            onPreviousWeek: () => context.read<WorkoutCubit>().navigateWeek(-1),
            onNextWeek: () => context.read<WorkoutCubit>().navigateWeek(1),
          ),
        ],
      ),
    );
  }
}

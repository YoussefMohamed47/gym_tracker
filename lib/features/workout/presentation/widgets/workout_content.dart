import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import 'daily_routine_section.dart';
import 'exercise_log_card.dart';

class WorkoutContent extends StatelessWidget {
  final WorkoutState state;
  final Function(String plannedId, String currentPerformedId) onSelectAlternative;
  final Function(String exerciseId) onAddPhoto;
  final Function(String exerciseId, String name) onShowHistory;

  const WorkoutContent({
    super.key,
    required this.state,
    required this.onSelectAlternative,
    required this.onAddPhoto,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == WorkoutStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final workoutDef = WorkoutCatalog.getWorkoutByType(state.workoutType);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (state.workoutType == WorkoutType.rest) ...[
          const SizedBox(height: 32),
          Icon(
            Icons.coffee,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Rest Day',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('Active recovery and proper nutrition!')),
          const SizedBox(height: 24),
        ],
        const DailyRoutineSection(),
        if (state.workoutType != WorkoutType.rest && workoutDef != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Exercises',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ...workoutDef.exercises.map((slot) {
            final log = state.exerciseLogs[slot.exerciseId];
            if (log == null) return const SizedBox.shrink();

            final performedExercise = WorkoutCatalog.getExerciseById(
              log.performedExerciseId,
            );

            return ExerciseLogCard(
              log: log,
              slot: slot,
              displayUnit: state.displayUnit,
              onWeightChanged: (setIndex, weight) {
                context.read<WorkoutCubit>().updateSetWeight(
                      slot.exerciseId,
                      setIndex,
                      weight,
                      log.displayUnit,
                    );
              },
              onRepsChanged: (setIndex, reps) {
                context.read<WorkoutCubit>().updateSetReps(
                      slot.exerciseId,
                      setIndex,
                      reps,
                    );
              },
              onToggleSetPerformed: (setIndex) {
                context.read<WorkoutCubit>().toggleSetPerformed(
                      slot.exerciseId,
                      setIndex,
                    );
              },
              onUnitChanged: (unit) {
                context.read<WorkoutCubit>().updateExerciseUnit(
                      slot.exerciseId,
                      unit,
                    );
              },
              onSelectAlternative: () => onSelectAlternative(
                slot.exerciseId,
                log.performedExerciseId,
              ),
              onAddPhoto: () => onAddPhoto(slot.exerciseId),
              onShowHistory: () => onShowHistory(
                log.performedExerciseId,
                performedExercise.name,
              ),
              onUseLegacyWeight: () => context
                  .read<WorkoutCubit>()
                  .useLegacyWeightForAllSets(slot.exerciseId),
            );
          }),
        ] else if (state.workoutType != WorkoutType.rest && workoutDef == null)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No workout definition found.')),
          ),
      ],
    );
  }
}

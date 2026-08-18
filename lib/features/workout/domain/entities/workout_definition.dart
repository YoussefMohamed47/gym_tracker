import 'workout_type.dart';

class WorkoutDefinition {
  final String id;
  final String name;
  final WorkoutType type;
  final List<ExerciseSlot> exercises;

  const WorkoutDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.exercises,
  });
}

class ExerciseSlot {
  final String exerciseId;
  final int prescribedSets;
  final String prescribedReps;
  final String prescribedRest;
  final int order;

  const ExerciseSlot({
    required this.exerciseId,
    required this.prescribedSets,
    required this.prescribedReps,
    required this.prescribedRest,
    required this.order,
  });
}

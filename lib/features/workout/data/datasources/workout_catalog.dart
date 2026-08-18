import '../../domain/entities/exercise_definition.dart';
import '../../domain/entities/workout_definition.dart';
import '../../domain/entities/workout_type.dart';

class WorkoutCatalog {
  static const List<ExerciseDefinition> exercises = [
    // Push Exercises
    ExerciseDefinition(
      id: 'push_chest_press_machine',
      name: 'Chest Press Machine',
      videoUrl: 'https://youtu.be/gRvjfajnZlY',
      alternatives: ['alt_db_bench_press'],
    ),
    ExerciseDefinition(
      id: 'push_incline_chest_press_machine',
      name: 'Incline Chest Press Machine',
      videoUrl: 'https://youtu.be/8iPEnn-ltC8',
      alternatives: ['alt_db_incline_bench_press'],
    ),
    ExerciseDefinition(
      id: 'push_shoulder_press_machine',
      name: 'Shoulder Press Machine',
      videoUrl: 'https://youtu.be/qEwKSRqnuzw',
      alternatives: ['alt_db_shoulder_press'],
    ),
    ExerciseDefinition(
      id: 'push_tricep_pushdown',
      name: 'Tricep Pushdown',
      videoUrl: 'https://youtu.be/2-LAMcpzHLU',
    ),
    ExerciseDefinition(
      id: 'push_lateral_raise',
      name: 'Lateral Raise',
      videoUrl: 'https://youtu.be/3VcKaXpzqRo',
    ),
    ExerciseDefinition(
      id: 'push_chest_fly',
      name: 'Chest Fly',
      videoUrl: 'https://youtu.be/Z57CtWotzAY',
    ),

    // Pull Exercises
    ExerciseDefinition(
      id: 'pull_t_bar_row',
      name: 'T-bar Row',
      videoUrl: 'https://youtu.be/H75im9fAUMc',
      alternatives: ['alt_chest_supported_db_row'],
    ),
    ExerciseDefinition(
      id: 'pull_sa_iso_lateral_lat_row',
      name: 'SA Iso-lateral Lat Row',
      videoUrl: 'https://youtu.be/dFzUjASsWKY',
      alternatives: ['alt_sa_db_row'],
    ),
    ExerciseDefinition(
      id: 'pull_lat_pulldown',
      name: 'Lat Pulldown',
      videoUrl: 'https://youtu.be/CAwf7n6Luuc',
    ),
    ExerciseDefinition(
      id: 'pull_face_pull',
      name: 'Face Pull',
      videoUrl: 'https://youtu.be/V8dZ3pyiCBo',
    ),
    ExerciseDefinition(
      id: 'pull_bicep_curl',
      name: 'Bicep Curl',
      videoUrl: 'https://youtu.be/ykJgrLQnKNo',
    ),
    ExerciseDefinition(
      id: 'pull_hammer_curl',
      name: 'Hammer Curl',
      videoUrl: 'https://youtu.be/7jadLJKbdd8',
    ),
    ExerciseDefinition(
      id: 'pull_rear_delt_fly',
      name: 'Rear Delt Fly',
      videoUrl: 'https://youtu.be/0G2JOZut1Rs',
    ),

    // Legs Exercises
    ExerciseDefinition(
      id: 'legs_leg_extension',
      name: 'Leg Extension',
      videoUrl: 'https://youtu.be/MeIiGifIkVo',
      alternatives: ['alt_goblet_squat'],
    ),
    ExerciseDefinition(
      id: 'legs_seated_leg_curl',
      name: 'Seated Leg Curl',
      videoUrl: 'https://youtu.be/uV0B9z-FqXw',
      alternatives: ['alt_db_leg_curl'],
    ),
    ExerciseDefinition(
      id: 'legs_adduction_machine',
      name: 'Adduction Machine',
      videoUrl: 'https://youtu.be/m9r_3rQ7y4o',
      alternatives: ['alt_banded_adduction'],
    ),
    ExerciseDefinition(
      id: 'legs_leg_press',
      name: 'Leg Press',
      videoUrl: 'https://youtu.be/IZxyjW7MPJQ',
    ),
    ExerciseDefinition(
      id: 'legs_rdl',
      name: 'Romanian Deadlift',
      videoUrl: 'https://youtu.be/2SHsk9alBAE',
    ),
    ExerciseDefinition(
      id: 'legs_calf_raise',
      name: 'Calf Raise',
      videoUrl: 'https://youtu.be/Y27m4pG2QJ8',
    ),

    // Alternatives (Standalone Definitions)
    ExerciseDefinition(id: 'alt_db_bench_press', name: 'DB Bench Press'),
    ExerciseDefinition(id: 'alt_db_incline_bench_press', name: 'DB Incline Bench Press'),
    ExerciseDefinition(id: 'alt_db_shoulder_press', name: 'DB Shoulder Press'),
    ExerciseDefinition(id: 'alt_chest_supported_db_row', name: 'Chest Supported DB Row'),
    ExerciseDefinition(id: 'alt_sa_db_row', name: 'SA DB Row'),
    ExerciseDefinition(id: 'alt_goblet_squat', name: 'Goblet Squat (Quad focus)'),
    ExerciseDefinition(id: 'alt_db_leg_curl', name: 'DB Leg Curl'),
    ExerciseDefinition(id: 'alt_banded_adduction', name: 'Banded Adduction'),

    // Daily Routine (Special)
    ExerciseDefinition(
      id: 'routine_mobility_flow',
      name: 'Mobility Flow',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'routine_core_stability',
      name: 'Core Stability',
      isWeightAllowed: false,
    ),
  ];

  static const List<WorkoutDefinition> workouts = [
    WorkoutDefinition(
      id: 'pull',
      name: 'Pull',
      type: WorkoutType.pull,
      exercises: [
        ExerciseSlot(exerciseId: 'pull_t_bar_row', order: 1, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'pull_sa_iso_lateral_lat_row', order: 2, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'pull_lat_pulldown', order: 3, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'pull_face_pull', order: 4, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '60s'),
        ExerciseSlot(exerciseId: 'pull_bicep_curl', order: 5, prescribedSets: 3, prescribedReps: '10-12', prescribedRest: '60s'),
        ExerciseSlot(exerciseId: 'pull_hammer_curl', order: 6, prescribedSets: 3, prescribedReps: '10-12', prescribedRest: '60s'),
        ExerciseSlot(exerciseId: 'pull_rear_delt_fly', order: 7, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '60s'),
      ],
    ),
    WorkoutDefinition(
      id: 'legs',
      name: 'Legs',
      type: WorkoutType.legs,
      exercises: [
        ExerciseSlot(exerciseId: 'legs_leg_extension', order: 1, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'legs_seated_leg_curl', order: 2, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'legs_leg_press', order: 3, prescribedSets: 3, prescribedReps: '10-12', prescribedRest: '120s'),
        ExerciseSlot(exerciseId: 'legs_rdl', order: 4, prescribedSets: 3, prescribedReps: '8-10', prescribedRest: '120s'),
        ExerciseSlot(exerciseId: 'legs_adduction_machine', order: 5, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '60s'),
        ExerciseSlot(exerciseId: 'legs_calf_raise', order: 6, prescribedSets: 3, prescribedReps: '15-20', prescribedRest: '60s'),
      ],
    ),
    WorkoutDefinition(
      id: 'push',
      name: 'Push',
      type: WorkoutType.push,
      exercises: [
        ExerciseSlot(exerciseId: 'push_chest_press_machine', order: 1, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'push_incline_chest_press_machine', order: 2, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'push_shoulder_press_machine', order: 3, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'push_lateral_raise', order: 4, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '60s'),
        ExerciseSlot(exerciseId: 'push_chest_fly', order: 5, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '60s'),
        ExerciseSlot(exerciseId: 'push_tricep_pushdown', order: 6, prescribedSets: 3, prescribedReps: '10-12', prescribedRest: '60s'),
      ],
    ),
    // Placeholder for Upper/Lower if needed to follow schedule
    WorkoutDefinition(
      id: 'upper',
      name: 'Upper Body',
      type: WorkoutType.upper,
      exercises: [
         ExerciseSlot(exerciseId: 'push_chest_press_machine', order: 1, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
         ExerciseSlot(exerciseId: 'pull_t_bar_row', order: 2, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
         ExerciseSlot(exerciseId: 'push_shoulder_press_machine', order: 3, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
         ExerciseSlot(exerciseId: 'pull_lat_pulldown', order: 4, prescribedSets: 3, prescribedReps: '8-12', prescribedRest: '90s'),
      ],
    ),
    WorkoutDefinition(
      id: 'lower',
      name: 'Lower Body',
      type: WorkoutType.lower,
      exercises: [
        ExerciseSlot(exerciseId: 'legs_leg_press', order: 1, prescribedSets: 3, prescribedReps: '10-12', prescribedRest: '120s'),
        ExerciseSlot(exerciseId: 'legs_rdl', order: 2, prescribedSets: 3, prescribedReps: '8-10', prescribedRest: '120s'),
        ExerciseSlot(exerciseId: 'legs_leg_extension', order: 3, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '90s'),
        ExerciseSlot(exerciseId: 'legs_seated_leg_curl', order: 4, prescribedSets: 3, prescribedReps: '12-15', prescribedRest: '90s'),
      ],
    ),
  ];

  static WorkoutDefinition? getWorkoutForDate(DateTime date) {
    // Sun=Pull (7), Mon=Legs (1), Tue=Rest (2), Wed=Upper (3), Thu=Lower (4), Fri=Rest (5), Sat=Push (6)
    // DateTime.weekday: Mon=1, ..., Sun=7
    switch (date.weekday) {
      case DateTime.sunday:
        return workouts.firstWhere((w) => w.type == WorkoutType.pull);
      case DateTime.monday:
        return workouts.firstWhere((w) => w.type == WorkoutType.legs);
      case DateTime.tuesday:
        return null; // Rest
      case DateTime.wednesday:
        return workouts.firstWhere((w) => w.type == WorkoutType.upper);
      case DateTime.thursday:
        return workouts.firstWhere((w) => w.type == WorkoutType.lower);
      case DateTime.friday:
        return null; // Rest
      case DateTime.saturday:
        return workouts.firstWhere((w) => w.type == WorkoutType.push);
      default:
        return null;
    }
  }

  static ExerciseDefinition getExerciseById(String id) {
    return exercises.firstWhere(
      (e) => e.id == id,
      orElse: () => ExerciseDefinition(id: id, name: 'Unknown Exercise'),
    );
  }
}

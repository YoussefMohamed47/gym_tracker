import '../../domain/entities/exercise_definition.dart';
import '../../domain/entities/workout_definition.dart';
import '../../domain/entities/workout_type.dart';

class WorkoutCatalog {
  static const List<ExerciseDefinition> exercises = [
    // --- PUSH (Saturday) ---
    ExerciseDefinition(
      id: 'push_chest_press_machine',
      name: 'chest press machine',
      videoUrl: 'https://youtu.be/vnd-GBtTMLI?si=QpCyy_EEtcNHVN10',
      alternatives: ['alt_db_bench_press'],
    ),
    ExerciseDefinition(
      id: 'push_incline_chest_press_machine',
      name: 'Incline chest press machine',
      videoUrl: 'https://youtu.be/bbbiEEAEsP8?si=Fc0PZfw-NdNg-9ee',
      alternatives: ['alt_db_incline_bench_press'],
    ),
    ExerciseDefinition(
      id: 'push_shoulder_press_machine',
      name: 'Shoulder press machine',
      videoUrl: 'https://youtu.be/MjVDrYPD7Rs?si=AypoYflVjEL4O4g5',
      alternatives: ['alt_db_shoulder_press'],
    ),
    ExerciseDefinition(
      id: 'push_cable_lateral_raises',
      name: 'Cable lateral raises',
      videoUrl: 'https://youtu.be/vFODLn4zEHk?si=bHtMI9YkFJaWVWw5',
    ),
    ExerciseDefinition(
      id: 'push_sa_triceps_over_head_extension',
      name: 'SA triceps over head extension',
      videoUrl: 'https://youtu.be/FE_AsjcTImc?si=83uGv-7ZZqMXtlCn',
    ),
    ExerciseDefinition(
      id: 'push_triceps_push_down',
      name: 'Triceps push down',
      videoUrl: 'https://youtube.com/shorts/WjLJ7zIppXQ?si=2F4GVDQYVmElNolD',
    ),

    // --- PULL (Sunday) ---
    ExerciseDefinition(
      id: 'pull_t_bar_row',
      name: 'T-bar row',
      videoUrl: 'https://youtu.be/BVSTYt02SuY?si=V4wqQxy6ryCl9idR',
      alternatives: ['alt_chest_supported_db_row'],
    ),
    ExerciseDefinition(
      id: 'pull_sa_lat_pull_down',
      name: 'SA lat pull down',
      videoUrl: 'https://youtu.be/bCjRRJ2lI8Y?si=iXhhCxKgogimdqyH',
    ),
    ExerciseDefinition(
      id: 'pull_sa_iso_lateral_lat_row',
      name: 'SA iso-lateral lat row',
      videoUrl: 'https://youtu.be/SJRCqL85ypE?si=WUQbYJEoANYH6pGe',
      alternatives: ['alt_sa_db_row'],
    ),
    ExerciseDefinition(
      id: 'pull_cable_rear_delt_fly',
      name: 'Cable rear delt fly',
      videoUrl: 'https://youtube.com/shorts/P5CXx_jgTDE?si=qOrErIqzLz2Y4bIk',
    ),
    ExerciseDefinition(
      id: 'pull_sa_db_preacher_bicep_curl',
      name: 'SA DB preacher bicep curl',
      videoUrl: 'https://youtube.com/shorts/oHHNXMLvs1c?si=H2RRkomltgOITqGf',
    ),
    ExerciseDefinition(
      id: 'pull_cable_hammer_curl',
      name: 'Cable hammer curl',
      videoUrl: 'https://youtube.com/shorts/FO5UpcspYpE?si=qpnKWY_y00v_FGRo',
    ),
    ExerciseDefinition(
      id: 'pull_db_shrugs',
      name: 'DB shrugs',
      videoUrl: 'https://youtube.com/shorts/rFsSeClGnNA?si=vLn4ffTmYiezyOah',
    ),

    // --- LEGS (Monday) ---
    ExerciseDefinition(
      id: 'legs_body_weighted_squat',
      name: 'Body weighted squat',
      videoUrl: 'https://youtube.com/shorts/-5LhNSMBrEs?si=iQZlcmTllyBih47K',
    ),
    ExerciseDefinition(
      id: 'legs_leg_extension',
      name: 'Leg extension',
      videoUrl: 'https://youtube.com/shorts/2zZ3vkPsExQ?si=2VhT0zPCafluamKJ',
      alternatives: ['alt_goblet_squat'],
    ),
    ExerciseDefinition(
      id: 'legs_adduction_machine',
      name: 'Adduction machine',
      videoUrl: 'https://youtu.be/mvIxYwz-Vkg?si=WLG9CIR_9PEBC_0_',
      alternatives: ['alt_banded_adduction'],
    ),
    ExerciseDefinition(
      id: 'legs_body_weighted_hip_thrust',
      name: 'Body weighted hip thrust',
      videoUrl: 'https://youtube.com/shorts/rc9O9xpwqUY?si=new5g778w3nPQjbh',
    ),
    ExerciseDefinition(
      id: 'legs_seated_leg_press_calve_raises',
      name: 'Seated leg press calve raises',
      videoUrl: 'https://youtu.be/dhRz1Ns60Zg?si=Snzzr5L6zQnf1-Sy',
    ),
    ExerciseDefinition(
      id: 'legs_child_pose',
      name: 'Child pose',
      videoUrl: 'https://youtu.be/_ZX_zTOBgp8?si=XTaRA5V3t5o40T19',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'legs_banded_pallof_twist',
      name: 'Banded pallof twist',
      videoUrl: 'https://youtube.com/shorts/KqjqO96zRrw?si=pFdbtJ2aM8mmE4Nc',
    ),

    // --- UPPER (Wednesday) ---
    ExerciseDefinition(
      id: 'upper_chest_fly_machine',
      name: 'Chest fly machine',
      videoUrl: 'https://youtube.com/shorts/fEdkcOlW8EA?si=FsrUnpglhF4nnI-8',
    ),
    ExerciseDefinition(
      id: 'upper_cable_pull_over',
      name: 'Cable pull over',
      videoUrl: 'https://youtube.com/shorts/lFyE8SXUNg4?si=CV5_3TawaXwW7rFL',
    ),
    ExerciseDefinition(
      id: 'upper_cable_lateral_raises',
      name: 'Cable lateral raises',
      videoUrl: 'https://youtube.com/shorts/PTuTD6q4kPY?si=CNDIRM0ILAzC66Hb',
    ),
    ExerciseDefinition(
      id: 'upper_no_cheat_db_bicep_curl',
      name: 'No cheat DB bicep curl',
      videoUrl: 'https://youtube.com/shorts/sCn19vd8kVI?si=9F1euEysCBypd3Ia',
    ),
    ExerciseDefinition(
      id: 'upper_sa_triceps_over_head_extension',
      name: 'SA triceps over head extension',
      videoUrl: 'https://youtu.be/FE_AsjcTImc?si=83uGv-7ZZqMXtlCn',
    ),
    ExerciseDefinition(
      id: 'upper_reverse_curl',
      name: 'Reverse curl',
      videoUrl: 'https://youtu.be/HwB-DevuJjU?si=k8UUoCpggYyUbM6F',
    ),
    ExerciseDefinition(
      id: 'upper_db_shrugs',
      name: 'DB shrugs',
      videoUrl: 'https://youtube.com/shorts/rFsSeClGnNA?si=vLn4ffTmYiezyOah',
    ),

    // --- LOWER (Thursday) ---
    ExerciseDefinition(
      id: 'lower_body_weighted_rdl',
      name: 'Body weighted RDL',
      videoUrl: 'https://youtu.be/wFF_ZUaaObc?si=UQF6lQOJbX4GnMXW',
    ),
    ExerciseDefinition(
      id: 'lower_seated_leg_curl',
      name: 'Seated leg curl',
      videoUrl: 'https://youtube.com/shorts/mh7hFEsTFbw?si=aT4zjtNlxGMq8-NO',
      alternatives: ['alt_db_leg_curl'],
    ),
    ExerciseDefinition(
      id: 'lower_adduction_machine',
      name: 'Adduction machine',
      videoUrl: 'https://youtube.com/shorts/K0tIapJBLS4?si=5dsWYf7V6Fbjscqp',
      alternatives: ['alt_banded_adduction'],
    ),
    ExerciseDefinition(
      id: 'lower_seated_leg_press_calve_raises',
      name: 'Seated leg press calve raises',
      videoUrl: 'https://youtu.be/dhRz1Ns60Zg?si=Snzzr5L6zQnf1-Sy',
    ),
    ExerciseDefinition(
      id: 'lower_dead_bug',
      name: 'Dead bug',
      videoUrl: 'https://youtu.be/jbWmbhElf3Q?si=n7rAuGqfLAqz9RJd',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'lower_standing_ql_db_extension',
      name: 'Standing QL DB extension',
      videoUrl: 'https://youtu.be/YjuUrq0nir0?si=AfQDXEKjzL98iyLQ',
    ),

    // --- DAILY ROUTINE ---
    ExerciseDefinition(
      id: 'routine_slr',
      name: 'SLR',
      videoUrl: 'https://youtu.be/U4L_6JEv9Jg?si=3vqYQvVuYi42hdN3',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'routine_clam_shell',
      name: 'Clam shell',
      videoUrl: 'https://youtu.be/DAAjOdwZdks?si=Kpxnx6gcebrxr4d5',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'routine_neurodynamic_sciatic_nerve',
      name: 'neurodynamic sciatic nerve',
      videoUrl: 'https://youtube.com/shorts/hvXv_Pm63Gg?si=aNB3AnDleusgf2nZ',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'routine_trunk_rotation',
      name: 'Trunk rotation',
      videoUrl: 'https://youtu.be/IhP0LP-wyxQ?si=By5boLC7DGyZH6Hg',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'routine_double_knee_to_chest',
      name: 'Double knee to chest',
      videoUrl: 'https://youtu.be/5R7eWaNWO3U?si=qBA8FC2j5sivSn7h',
      isWeightAllowed: false,
    ),

    // --- ALTERNATIVES ---
    ExerciseDefinition(id: 'alt_db_bench_press', name: 'DB Bench Press'),
    ExerciseDefinition(
      id: 'alt_db_incline_bench_press',
      name: 'DB Incline Bench Press',
    ),
    ExerciseDefinition(id: 'alt_db_shoulder_press', name: 'DB Shoulder Press'),
    ExerciseDefinition(
      id: 'alt_chest_supported_db_row',
      name: 'Chest Supported DB Row',
    ),
    ExerciseDefinition(id: 'alt_sa_db_row', name: 'SA DB Row'),
    ExerciseDefinition(
      id: 'alt_goblet_squat',
      name: 'Goblet Squat (Quad focus)',
    ),
    ExerciseDefinition(id: 'alt_db_leg_curl', name: 'DB Leg Curl'),
    ExerciseDefinition(id: 'alt_banded_adduction', name: 'Banded Adduction'),

    // --- LEGACY / TOMBSTONES ---
    ExerciseDefinition(
      id: 'push_chest_fly',
      name: 'Chest Fly',
      videoUrl: 'https://youtu.be/Z57CtWotzAY',
    ),
    ExerciseDefinition(
      id: 'push_lateral_raise',
      name: 'Lateral Raise (Legacy)',
    ),
    ExerciseDefinition(
      id: 'push_tricep_pushdown',
      name: 'Tricep Pushdown (Legacy)',
    ),
    ExerciseDefinition(id: 'pull_lat_pulldown', name: 'Lat Pulldown (Legacy)'),
    ExerciseDefinition(id: 'pull_face_pull', name: 'Face Pull (Legacy)'),
    ExerciseDefinition(id: 'pull_bicep_curl', name: 'Bicep Curl (Legacy)'),
    ExerciseDefinition(id: 'pull_hammer_curl', name: 'Hammer Curl (Legacy)'),
    ExerciseDefinition(
      id: 'pull_rear_delt_fly',
      name: 'Rear Delt Fly (Legacy)',
    ),
    ExerciseDefinition(id: 'legs_leg_press', name: 'Leg Press (Legacy)'),
    ExerciseDefinition(id: 'legs_rdl', name: 'Romanian Deadlift (Legacy)'),
    ExerciseDefinition(id: 'legs_calf_raise', name: 'Calf Raise (Legacy)'),
  ];

  static const List<WorkoutDefinition> workouts = [
    WorkoutDefinition(
      id: 'pull',
      name: 'Pull',
      type: WorkoutType.pull,
      exercises: [
        ExerciseSlot(
          exerciseId: 'pull_t_bar_row',
          order: 1,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'pull_sa_lat_pull_down',
          order: 2,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'pull_sa_iso_lateral_lat_row',
          order: 3,
          prescribedSets: 2,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'pull_cable_rear_delt_fly',
          order: 4,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'pull_sa_db_preacher_bicep_curl',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'pull_cable_hammer_curl',
          order: 6,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'pull_db_shrugs',
          order: 7,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'legs',
      name: 'Legs',
      type: WorkoutType.legs,
      exercises: [
        ExerciseSlot(
          exerciseId: 'legs_body_weighted_squat',
          order: 1,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'legs_leg_extension',
          order: 2,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'legs_adduction_machine',
          order: 3,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'legs_body_weighted_hip_thrust',
          order: 4,
          prescribedSets: 2,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'legs_seated_leg_press_calve_raises',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'legs_child_pose',
          order: 6,
          prescribedSets: 2,
          prescribedReps: '15-45s',
          prescribedRest: '1m',
        ),
        ExerciseSlot(
          exerciseId: 'legs_banded_pallof_twist',
          order: 7,
          prescribedSets: 2,
          prescribedReps: '5-15',
          prescribedRest: '1m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'push',
      name: 'Push',
      type: WorkoutType.push,
      exercises: [
        ExerciseSlot(
          exerciseId: 'push_chest_press_machine',
          order: 1,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'push_incline_chest_press_machine',
          order: 2,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'push_shoulder_press_machine',
          order: 3,
          prescribedSets: 2,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'push_cable_lateral_raises',
          order: 4,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'push_sa_triceps_over_head_extension',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'push_triceps_push_down',
          order: 6,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'upper',
      name: 'Upper',
      type: WorkoutType.upper,
      exercises: [
        ExerciseSlot(
          exerciseId: 'upper_chest_fly_machine',
          order: 1,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'upper_cable_pull_over',
          order: 2,
          prescribedSets: 4,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'upper_cable_lateral_raises',
          order: 3,
          prescribedSets: 2,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'upper_no_cheat_db_bicep_curl',
          order: 4,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'upper_sa_triceps_over_head_extension',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'upper_reverse_curl',
          order: 6,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'upper_db_shrugs',
          order: 7,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'lower',
      name: 'Lower',
      type: WorkoutType.lower,
      exercises: [
        ExerciseSlot(
          exerciseId: 'lower_body_weighted_rdl',
          order: 1,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'lower_seated_leg_curl',
          order: 2,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'lower_adduction_machine',
          order: 3,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'lower_seated_leg_press_calve_raises',
          order: 4,
          prescribedSets: 3,
          prescribedReps: '8-12',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'lower_dead_bug',
          order: 5,
          prescribedSets: 2,
          prescribedReps: '5-15',
          prescribedRest: '1m',
        ),
        ExerciseSlot(
          exerciseId: 'lower_standing_ql_db_extension',
          order: 6,
          prescribedSets: 2,
          prescribedReps: '5-15',
          prescribedRest: '1m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'daily_routine',
      name: 'Daily Routine',
      type: WorkoutType.rest, // Type doesn't matter much for Daily Routine
      exercises: [
        ExerciseSlot(
          exerciseId: 'routine_slr',
          order: 1,
          prescribedSets: 2,
          prescribedReps: '5-15',
          prescribedRest: '1m',
        ),
        ExerciseSlot(
          exerciseId: 'routine_clam_shell',
          order: 2,
          prescribedSets: 2,
          prescribedReps: '5-15',
          prescribedRest: '1m',
        ),
        ExerciseSlot(
          exerciseId: 'routine_neurodynamic_sciatic_nerve',
          order: 3,
          prescribedSets: 2,
          prescribedReps: '5-15',
          prescribedRest: '1m',
        ),
        ExerciseSlot(
          exerciseId: 'routine_trunk_rotation',
          order: 4,
          prescribedSets: 2,
          prescribedReps: '5-15',
          prescribedRest: '1m',
        ),
        ExerciseSlot(
          exerciseId: 'routine_double_knee_to_chest',
          order: 5,
          prescribedSets: 5,
          prescribedReps: '10s',
          prescribedRest: '30s',
        ),
      ],
    ),
  ];

  static WorkoutDefinition? getWorkoutForDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.sunday:
        return workouts.firstWhere((w) => w.id == 'pull');
      case DateTime.monday:
        return workouts.firstWhere((w) => w.id == 'legs');
      case DateTime.tuesday:
        return null; // Rest
      case DateTime.wednesday:
        return workouts.firstWhere((w) => w.id == 'upper');
      case DateTime.thursday:
        return workouts.firstWhere((w) => w.id == 'lower');
      case DateTime.friday:
        return null; // Rest
      case DateTime.saturday:
        return workouts.firstWhere((w) => w.id == 'push');
      default:
        return null;
    }
  }

  static WorkoutDefinition getDailyRoutine() {
    return workouts.firstWhere((w) => w.id == 'daily_routine');
  }

  static ExerciseDefinition getExerciseById(String id) {
    return exercises.firstWhere(
      (e) => e.id == id,
      orElse: () => ExerciseDefinition(id: id, name: 'Unknown Exercise'),
    );
  }
}

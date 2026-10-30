import '../../domain/entities/exercise_definition.dart';
import '../../domain/entities/workout_definition.dart';
import '../../domain/entities/workout_type.dart';
import '../../utils/date_utils.dart';

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
    ExerciseDefinition(
      id: 'push_forearm_exercise_variations',
      name: 'Forearm exercise variations',
      videoUrl: 'https://youtube.com/shorts/d5YiFNoiCa0?si=CHJQ5lqA1SJd-l_w',
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
    ExerciseDefinition(
      id: 'pull_forearm_exercise_variations',
      name: 'Forearm exercise variations',
      videoUrl: 'https://youtube.com/shorts/d5YiFNoiCa0?si=CHJQ5lqA1SJd-l_w',
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
    ExerciseDefinition(
      id: 'upper_forearm_exercise_variations',
      name: 'Forearm exercise variations',
      videoUrl: 'https://youtube.com/shorts/d5YiFNoiCa0?si=CHJQ5lqA1SJd-l_w',
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

    // --- UPPER BODY WARM-UP ---
    ExerciseDefinition(
      id: 'warmup_banded_shoulder_circles',
      name: 'Banded Shoulder Circles',
      videoUrl: 'https://youtube.com/shorts/4CgzlcxpX6c',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'warmup_banded_external_rotation',
      name: 'Banded External Rotation',
      videoUrl: 'https://youtube.com/shorts/itrfhrP03sg',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'warmup_banded_scapula_push_up',
      name: 'Banded Scapula Push Up',
      videoUrl: 'https://youtube.com/shorts/e0xZY2exolw',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'warmup_banded_single_arm_row',
      name: 'Single Arm Banded Row',
      videoUrl: 'https://www.youtube.com/watch?v=I5cBCIhT9fI',
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

    // --- 8-DAY ROTATING CATALOG EXERCISES ---
    // Day 1: Chest & Back
    ExerciseDefinition(
      id: 'c_incline_chest_press_smith',
      name: 'Incline Chest Press Smith Machine',
      videoUrl: 'https://youtube.com/shorts/VXaBbUYMfIs',
      tempoNote: 'Light weight, slow tempo',
      alternatives: ['alt_db_incline_bench_press', 'c_db_chest_press'],
    ),
    ExerciseDefinition(
      id: 'c_db_chest_press',
      name: 'DB Chest Press',
      videoUrl: 'https://youtube.com/shorts/mTaiQemkEpU',
      tempoNote: 'Light weight, slow tempo',
      alternatives: ['alt_db_bench_press', 'c_incline_chest_press_smith'],
    ),
    ExerciseDefinition(
      id: 'c_high_to_low_cable_chest_fly',
      name: 'High to Low Cable Chest Fly',
      videoUrl: 'https://youtube.com/shorts/AB3Fj_O2EL4',
      tempoNote: 'Light weight, slow tempo',
      alternatives: ['c_chest_fly_machine', 'push_chest_fly'],
    ),
    ExerciseDefinition(
      id: 'c_t_bar_row_machine',
      name: 'T-Bar Row Machine',
      videoUrl: 'https://youtube.com/shorts/ZbOUxXRS42s',
      alternatives: ['alt_chest_supported_db_row', 'c_dh_v_grip_cable_row'],
    ),
    ExerciseDefinition(
      id: 'c_sa_cable_lat_row',
      name: 'SA Cable Lat Row',
      videoUrl: 'https://youtu.be/1jN6qeXdvWA',
      alternatives: ['alt_sa_db_row', 'c_sa_db_lat_row'],
    ),
    ExerciseDefinition(
      id: 'c_cable_shrugs',
      name: 'Cable Shrugs',
      videoUrl: 'https://youtube.com/shorts/Y77EtpS8CL0',
    ),

    // Day 2: Shoulder & Arms
    ExerciseDefinition(
      id: 'c_scapular_plane_db_lateral_raises',
      name: 'Scapular Plane DB Lateral Raises',
      videoUrl: 'https://youtube.com/shorts/czKlnVCSJPM',
      tempoNote: 'Light weight, slow tempo',
      alternatives: ['push_cable_lateral_raises', 'push_lateral_raise'],
    ),
    ExerciseDefinition(
      id: 'c_incline_db_bicep_curl',
      name: 'Incline DB Bicep Curl',
      videoUrl: 'https://youtube.com/shorts/uCUaRFlA9vE',
      alternatives: ['c_db_bicep_curl', 'pull_cable_hammer_curl'],
    ),
    ExerciseDefinition(
      id: 'c_sa_triceps_push_down',
      name: 'SA Triceps Push Down',
      videoUrl: 'https://youtube.com/shorts/w5a5sErWIEw',
      alternatives: ['push_triceps_push_down', 'push_sa_triceps_over_head_extension'],
    ),
    ExerciseDefinition(
      id: 'c_rear_delt_machine_fly',
      name: 'Rear Delt Machine Fly',
      videoUrl: 'https://youtube.com/shorts/7tgx6QHB0-A',
      alternatives: ['pull_cable_rear_delt_fly'],
    ),
    ExerciseDefinition(
      id: 'c_sa_db_preacher_hammer_curl',
      name: 'SA DB Preacher Hammer Curl',
      videoUrl: 'https://youtube.com/shorts/oHbSWPo3swM',
      alternatives: ['pull_sa_db_preacher_bicep_curl'],
    ),
    ExerciseDefinition(
      id: 'c_cable_wrist_flexion',
      name: 'Cable Wrist Flexion',
      videoUrl: 'https://youtu.be/WVAaKJvToe0',
      alternatives: ['push_forearm_exercise_variations'],
    ),
    ExerciseDefinition(
      id: 'c_cable_wrist_extension',
      name: 'Cable Wrist Extension',
      videoUrl: 'https://youtube.com/shorts/_JiYn7I9F_k',
      alternatives: ['push_forearm_exercise_variations'],
    ),

    // Day 3: Legs
    ExerciseDefinition(
      id: 'c_leg_press_machine',
      name: 'Leg Press Machine',
      videoUrl: 'https://youtu.be/q4W4_VJbKW0',
      alternatives: ['alt_goblet_squat', 'legs_body_weighted_squat'],
    ),
    ExerciseDefinition(
      id: 'c_leg_extension',
      name: 'Leg Extension',
      videoUrl: 'https://youtube.com/shorts/2zZ3vkPsExQ',
      alternatives: ['alt_goblet_squat'],
    ),
    ExerciseDefinition(
      id: 'c_adduction_machine',
      name: 'Adduction Machine',
      videoUrl: 'https://youtu.be/mvIxYwz-Vkg',
      alternatives: ['alt_banded_adduction'],
    ),
    ExerciseDefinition(
      id: 'c_db_hip_thrust',
      name: 'DB Hip Thrust',
      videoUrl: 'https://youtube.com/shorts/QqtLsnNthbA',
    ),
    ExerciseDefinition(
      id: 'c_standing_calf_raises_machine',
      name: 'Standing Calf Raises Machine',
      videoUrl: 'https://youtube.com/shorts/95itLfMBG40',
      alternatives: ['legs_calf_raise'],
    ),
    ExerciseDefinition(
      id: 'c_cat_cow',
      name: 'Cat Cow',
      videoUrl: 'https://youtube.com/shorts/FyCuSE3mDcc',
      isWeightAllowed: false,
    ),
    ExerciseDefinition(
      id: 'c_bird_dog_hold',
      name: 'Bird Dog Hold',
      videoUrl: 'https://youtube.com/shorts/knsOPG88idk',
      isWeightAllowed: false,
    ),

    // Day 5: Full Body
    ExerciseDefinition(
      id: 'c_chest_fly_machine',
      name: 'Chest Fly Machine',
      videoUrl: 'https://youtu.be/eGjt4lk6g34',
      tempoNote: 'Light weight, slow tempo',
      alternatives: ['c_high_to_low_cable_chest_fly', 'push_chest_fly'],
    ),
    ExerciseDefinition(
      id: 'c_dh_v_grip_cable_row',
      name: 'DH V Grip Cable Row',
      videoUrl: 'https://youtube.com/shorts/qD1WZ5pSuvk',
      alternatives: ['c_t_bar_row_machine', 'alt_chest_supported_db_row'],
    ),
    ExerciseDefinition(
      id: 'c_rear_delt_machine_fly_fb',
      name: 'Rear Delt Machine Fly',
      videoUrl: 'https://youtube.com/shorts/7tgx6QHB0-A',
      alternatives: ['pull_cable_rear_delt_fly'],
    ),
    ExerciseDefinition(
      id: 'c_db_bicep_curl',
      name: 'DB Bicep Curl',
      videoUrl: 'https://youtube.com/shorts/MKWBV29S6c0',
      alternatives: ['c_incline_db_bicep_curl', 'pull_cable_hammer_curl'],
    ),
    ExerciseDefinition(
      id: 'c_db_rdl',
      name: 'DB RDL',
      videoUrl: 'https://youtube.com/shorts/4-Gq43Y0OK4',
    ),
    ExerciseDefinition(
      id: 'c_seated_leg_curl',
      name: 'Seated Leg Curl',
      videoUrl: 'https://youtu.be/WGih6WFr3uI',
      alternatives: ['alt_db_leg_curl'],
    ),
    ExerciseDefinition(
      id: 'c_banded_glute_kick_back',
      name: 'Banded Glute Kick Back',
      videoUrl: 'https://youtu.be/rONpWaNIhE8',
      isWeightAllowed: false,
    ),

    // Day 7: Upper + Calves
    ExerciseDefinition(
      id: 'c_incline_chest_press_machine',
      name: 'Incline Chest Press Machine',
      videoUrl: 'https://youtube.com/shorts/VXaBbUYMfIs',
      tempoNote: 'Light weight, slow tempo',
      alternatives: ['c_incline_chest_press_smith', 'alt_db_incline_bench_press'],
    ),
    ExerciseDefinition(
      id: 'c_sa_db_lat_row',
      name: 'SA DB Lat Row',
      videoUrl: 'https://youtu.be/yHqqGd0tXcw',
      alternatives: ['c_sa_cable_lat_row', 'alt_sa_db_row'],
    ),
    ExerciseDefinition(
      id: 'c_db_kelso_shrugs',
      name: 'DB Kelso Shrugs',
      videoUrl: 'https://youtu.be/zX0c-WIIilk',
    ),
    ExerciseDefinition(
      id: 'c_scapular_plane_db_lateral_raises_uc',
      name: 'Scapular Plane DB Lateral Raises',
      videoUrl: 'https://youtube.com/shorts/czKlnVCSJPM',
      tempoNote: 'Light weight, slow tempo',
      alternatives: ['push_cable_lateral_raises', 'push_lateral_raise'],
    ),
    ExerciseDefinition(
      id: 'c_sa_cable_preacher_bicep_curl',
      name: 'SA Cable Preacher Bicep Curl',
      videoUrl: 'https://youtube.com/shorts/vyP7ggY_baE',
      alternatives: ['c_sa_db_bench_preacher_curl', 'c_sa_db_preacher_hammer_curl', 'pull_sa_db_preacher_bicep_curl'],
    ),
    // Alternative: SA DB Preacher curl on incline bench (one-arm dumbbell)
    ExerciseDefinition(
      id: 'c_sa_db_bench_preacher_curl',
      name: 'SA DB Bench Preacher Curl',
      videoUrl: 'https://www.instagram.com/reel/De2Dm8_ILOA/',
      alternatives: ['c_sa_cable_preacher_bicep_curl', 'pull_sa_db_preacher_bicep_curl'],
    ),
    ExerciseDefinition(
      id: 'c_sa_triceps_push_down_uc',
      name: 'SA Triceps Push Down',
      videoUrl: 'https://youtube.com/shorts/w5a5sErWIEw',
      alternatives: ['c_sa_triceps_push_down', 'push_triceps_push_down'],
    ),
    ExerciseDefinition(
      id: 'c_standing_calf_raises_machine_uc',
      name: 'Standing Calf Raises Machine',
      videoUrl: 'https://youtube.com/shorts/95itLfMBG40',
      alternatives: ['c_standing_calf_raises_machine', 'legs_calf_raise'],
    ),
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
        ExerciseSlot(
          exerciseId: 'pull_forearm_exercise_variations',
          order: 8,
          prescribedSets: 3,
          prescribedReps: '15',
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
        ExerciseSlot(
          exerciseId: 'push_forearm_exercise_variations',
          order: 7,
          prescribedSets: 3,
          prescribedReps: '15',
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
        ExerciseSlot(
          exerciseId: 'upper_forearm_exercise_variations',
          order: 8,
          prescribedSets: 3,
          prescribedReps: '15',
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
    WorkoutDefinition(
      id: 'upper_body_warmup',
      name: 'Upper Body Warm-up',
      type: WorkoutType.upper,
      exercises: [
        ExerciseSlot(
          exerciseId: 'warmup_banded_shoulder_circles',
          order: 1,
          prescribedSets: 1,
          prescribedReps: '10–12',
          prescribedRest: '30s',
        ),
        ExerciseSlot(
          exerciseId: 'warmup_banded_external_rotation',
          order: 2,
          prescribedSets: 2,
          prescribedReps: '12–15 / arm',
          prescribedRest: '30s',
        ),
        ExerciseSlot(
          exerciseId: 'warmup_banded_scapula_push_up',
          order: 3,
          prescribedSets: 1,
          prescribedReps: '10–12',
          prescribedRest: '30s',
        ),
        ExerciseSlot(
          exerciseId: 'warmup_banded_single_arm_row',
          order: 4,
          prescribedSets: 2,
          prescribedReps: '12 / arm',
          prescribedRest: '30s',
        ),
      ],
    ),

    // --- 8-DAY ROTATING CATALOG WORKOUTS ---
    WorkoutDefinition(
      id: 'chest_and_back',
      name: 'Chest & Back',
      type: WorkoutType.chestAndBack,
      exercises: [
        ExerciseSlot(
          exerciseId: 'c_incline_chest_press_smith',
          order: 1,
          prescribedSets: 2,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
          tempoNote: 'Light weight, slow tempo',
        ),
        ExerciseSlot(
          exerciseId: 'c_db_chest_press',
          order: 2,
          prescribedSets: 2,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
          tempoNote: 'Light weight, slow tempo',
        ),
        ExerciseSlot(
          exerciseId: 'c_high_to_low_cable_chest_fly',
          order: 3,
          prescribedSets: 2,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
          tempoNote: 'Light weight, slow tempo',
        ),
        ExerciseSlot(
          exerciseId: 'c_t_bar_row_machine',
          order: 4,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_sa_cable_lat_row',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_cable_shrugs',
          order: 6,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'shoulder_and_arms',
      name: 'Shoulder & Arms',
      type: WorkoutType.shoulderAndArms,
      exercises: [
        ExerciseSlot(
          exerciseId: 'c_scapular_plane_db_lateral_raises',
          order: 1,
          prescribedSets: 2,
          prescribedReps: '15-25',
          prescribedRest: '1-2m',
          tempoNote: 'Light weight, slow tempo',
        ),
        ExerciseSlot(
          exerciseId: 'c_incline_db_bicep_curl',
          order: 2,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_sa_triceps_push_down',
          order: 3,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_rear_delt_machine_fly',
          order: 4,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_sa_db_preacher_hammer_curl',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_cable_wrist_flexion',
          order: 6,
          prescribedSets: 2,
          prescribedReps: '6-10',
          prescribedRest: '1-2m',
        ),
        ExerciseSlot(
          exerciseId: 'c_cable_wrist_extension',
          order: 7,
          prescribedSets: 2,
          prescribedReps: '6-10',
          prescribedRest: '1-2m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'legs_8day',
      name: 'Legs',
      type: WorkoutType.legs,
      exercises: [
        ExerciseSlot(
          exerciseId: 'c_leg_press_machine',
          order: 1,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_leg_extension',
          order: 2,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_adduction_machine',
          order: 3,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_db_hip_thrust',
          order: 4,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_standing_calf_raises_machine',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_cat_cow',
          order: 6,
          prescribedSets: 2,
          prescribedReps: '10-15',
          prescribedRest: '1m',
        ),
        ExerciseSlot(
          exerciseId: 'c_bird_dog_hold',
          order: 7,
          prescribedSets: 2,
          prescribedReps: '10-20s',
          prescribedRest: '1m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'full_body',
      name: 'Full Body',
      type: WorkoutType.fullBody,
      exercises: [
        ExerciseSlot(
          exerciseId: 'c_chest_fly_machine',
          order: 1,
          prescribedSets: 2,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
          tempoNote: 'Light weight, slow tempo',
        ),
        ExerciseSlot(
          exerciseId: 'c_dh_v_grip_cable_row',
          order: 2,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_rear_delt_machine_fly_fb',
          order: 3,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_db_bicep_curl',
          order: 4,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_db_rdl',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_seated_leg_curl',
          order: 6,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_banded_glute_kick_back',
          order: 7,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
      ],
    ),
    WorkoutDefinition(
      id: 'upper_and_calves',
      name: 'Upper + Calves',
      type: WorkoutType.upperAndCalves,
      exercises: [
        ExerciseSlot(
          exerciseId: 'c_incline_chest_press_machine',
          order: 1,
          prescribedSets: 2,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
          tempoNote: 'Light weight, slow tempo',
        ),
        ExerciseSlot(
          exerciseId: 'c_sa_db_lat_row',
          order: 2,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_db_kelso_shrugs',
          order: 3,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_scapular_plane_db_lateral_raises_uc',
          order: 4,
          prescribedSets: 2,
          prescribedReps: '15-25',
          prescribedRest: '1-2m',
          tempoNote: 'Light weight, slow tempo',
        ),
        ExerciseSlot(
          exerciseId: 'c_sa_cable_preacher_bicep_curl',
          order: 5,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_sa_triceps_push_down_uc',
          order: 6,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
        ExerciseSlot(
          exerciseId: 'c_standing_calf_raises_machine_uc',
          order: 7,
          prescribedSets: 3,
          prescribedReps: '6-10',
          prescribedRest: '2-3m',
        ),
      ],
    ),
  ];

  static const List<WorkoutType> trainingSequence = [
    WorkoutType.chestAndBack,
    WorkoutType.shoulderAndArms,
    WorkoutType.legs,
    WorkoutType.rest,
    WorkoutType.fullBody,
    WorkoutType.rest,
    WorkoutType.upperAndCalves,
    WorkoutType.rest,
  ];

  static WorkoutType getNextWorkoutType(List<WorkoutType> history) {
    if (history.isEmpty) return trainingSequence.first;

    final last = history.first;

    if (last == WorkoutType.rest) {
      if (history.length > 1) {
        final prev = history[1];
        if (prev == WorkoutType.legs) return WorkoutType.fullBody;
        if (prev == WorkoutType.fullBody) return WorkoutType.upperAndCalves;
        if (prev == WorkoutType.upperAndCalves) return WorkoutType.chestAndBack;
        // legacy fallbacks
        if (prev == WorkoutType.lower) return WorkoutType.push;
      }
      return trainingSequence.first;
    }

    final index = trainingSequence.indexOf(last);
    if (index == -1) return trainingSequence.first;
    return trainingSequence[(index + 1) % trainingSequence.length];
  }

  static WorkoutDefinition? getWorkoutForDate(DateTime date) {
    final type = WorkoutDateUtils.getWorkoutTypeForDay(date);
    if (type == WorkoutType.rest) return null;
    return workouts.firstWhere(
      (w) => w.id == type.name,
      orElse: () => getWorkoutByType(type)!,
    );
  }

  static WorkoutDefinition? getWorkoutByType(WorkoutType type) {
    try {
      if (type == WorkoutType.legs) {
        final legs8Day = workouts.where((w) => w.id == 'legs_8day');
        if (legs8Day.isNotEmpty) return legs8Day.first;
      }
      return workouts.firstWhere(
        (w) =>
            w.type == type &&
            w.id != 'daily_routine' &&
            w.id != 'upper_body_warmup',
      );
    } catch (_) {
      return null;
    }
  }

  static WorkoutDefinition getDailyRoutine() {
    return workouts.firstWhere((w) => w.id == 'daily_routine');
  }

  static WorkoutDefinition getUpperBodyWarmup() {
    return workouts.firstWhere((w) => w.id == 'upper_body_warmup');
  }

  static ExerciseDefinition getExerciseById(String id) {
    return exercises.firstWhere(
      (e) => e.id == id,
      orElse: () => ExerciseDefinition(id: id, name: 'Unknown Exercise'),
    );
  }
}

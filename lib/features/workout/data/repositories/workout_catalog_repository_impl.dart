import '../../domain/entities/catalog_day.dart';
import '../../domain/entities/catalog_exercise.dart';
import '../../domain/entities/workout_type.dart';
import '../../domain/repositories/workout_catalog_repository.dart';

class WorkoutCatalogRepositoryImpl implements WorkoutCatalogRepository {
  static const String tempoNoteSlow = 'Light weight, slow tempo';

  static const List<CatalogDay> _eightDayRotation = [
    // DAY 1 — Chest & Back
    CatalogDay(
      dayNumber: 1,
      title: 'Chest & Back',
      workoutType: WorkoutType.chestAndBack,
      isRestDay: false,
      exercises: [
        CatalogExercise(
          id: 'c_incline_chest_press_smith',
          name: 'Incline Chest Press Smith Machine',
          sets: 2,
          repsRange: '6-10',
          restRange: '2-3m',
          tempoNote: tempoNoteSlow,
          videoUrl: 'https://youtube.com/shorts/VXaBbUYMfIs',
          alternatives: ['alt_db_incline_bench_press'],
        ),
        CatalogExercise(
          id: 'c_db_chest_press',
          name: 'DB Chest Press',
          sets: 2,
          repsRange: '6-10',
          restRange: '2-3m',
          tempoNote: tempoNoteSlow,
          videoUrl: 'https://youtube.com/shorts/mTaiQemkEpU',
          alternatives: ['alt_db_bench_press'],
        ),
        CatalogExercise(
          id: 'c_high_to_low_cable_chest_fly',
          name: 'High to Low Cable Chest Fly',
          sets: 2,
          repsRange: '6-10',
          restRange: '2-3m',
          tempoNote: tempoNoteSlow,
          videoUrl: 'https://youtube.com/shorts/AB3Fj_O2EL4',
          alternatives: ['push_chest_fly'],
        ),
        CatalogExercise(
          id: 'c_t_bar_row_machine',
          name: 'T-Bar Row Machine',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/ZbOUxXRS42s',
          alternatives: ['alt_chest_supported_db_row'],
        ),
        CatalogExercise(
          id: 'c_sa_cable_lat_row',
          name: 'SA Cable Lat Row',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtu.be/1jN6qeXdvWA',
          alternatives: ['alt_sa_db_row'],
        ),
        CatalogExercise(
          id: 'c_cable_shrugs',
          name: 'Cable Shrugs',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/Y77EtpS8CL0',
        ),
      ],
    ),

    // DAY 2 — Shoulder & Arms
    CatalogDay(
      dayNumber: 2,
      title: 'Shoulder & Arms',
      workoutType: WorkoutType.shoulderAndArms,
      isRestDay: false,
      exercises: [
        CatalogExercise(
          id: 'c_scapular_plane_db_lateral_raises',
          name: 'Scapular Plane DB Lateral Raises',
          sets: 2,
          repsRange: '15-25',
          restRange: '1-2m',
          tempoNote: tempoNoteSlow,
          videoUrl: 'https://youtube.com/shorts/czKlnVCSJPM',
          alternatives: ['push_cable_lateral_raises', 'push_lateral_raise'],
        ),
        CatalogExercise(
          id: 'c_incline_db_bicep_curl',
          name: 'Incline DB Bicep Curl',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/uCUaRFlA9vE',
          alternatives: ['pull_cable_hammer_curl'],
        ),
        CatalogExercise(
          id: 'c_sa_triceps_push_down',
          name: 'SA Triceps Push Down',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/w5a5sErWIEw',
          alternatives: ['push_triceps_push_down'],
        ),
        CatalogExercise(
          id: 'c_rear_delt_machine_fly',
          name: 'Rear Delt Machine Fly',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/7tgx6QHB0-A',
          alternatives: ['pull_cable_rear_delt_fly'],
        ),
        CatalogExercise(
          id: 'c_sa_db_preacher_hammer_curl',
          name: 'SA DB Preacher Hammer Curl',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/oHbSWPo3swM',
          alternatives: ['pull_sa_db_preacher_bicep_curl'],
        ),
        CatalogExercise(
          id: 'c_cable_wrist_flexion',
          name: 'Cable Wrist Flexion',
          sets: 2,
          repsRange: '6-10',
          restRange: '1-2m',
          videoUrl: 'https://youtu.be/WVAaKJvToe0',
          alternatives: ['push_forearm_exercise_variations'],
        ),
        CatalogExercise(
          id: 'c_cable_wrist_extension',
          name: 'Cable Wrist Extension',
          sets: 2,
          repsRange: '6-10',
          restRange: '1-2m',
          videoUrl: 'https://youtube.com/shorts/_JiYn7I9F_k',
          alternatives: ['push_forearm_exercise_variations'],
        ),
      ],
    ),

    // DAY 3 — Legs
    CatalogDay(
      dayNumber: 3,
      title: 'Legs',
      workoutType: WorkoutType.legs,
      isRestDay: false,
      exercises: [
        CatalogExercise(
          id: 'c_leg_press_machine',
          name: 'Leg Press Machine',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtu.be/q4W4_VJbKW0',
          alternatives: ['alt_goblet_squat'],
        ),
        CatalogExercise(
          id: 'c_leg_extension',
          name: 'Leg Extension',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/2zZ3vkPsExQ',
          alternatives: ['alt_goblet_squat'],
        ),
        CatalogExercise(
          id: 'c_adduction_machine',
          name: 'Adduction Machine',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtu.be/mvIxYwz-Vkg',
          alternatives: ['alt_banded_adduction'],
        ),
        CatalogExercise(
          id: 'c_db_hip_thrust',
          name: 'DB Hip Thrust',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/QqtLsnNthbA',
        ),
        CatalogExercise(
          id: 'c_standing_calf_raises_machine',
          name: 'Standing Calf Raises Machine',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/95itLfMBG40',
        ),
        CatalogExercise(
          id: 'c_cat_cow',
          name: 'Cat Cow',
          sets: 2,
          repsRange: '10-15',
          restRange: '1m',
          videoUrl: 'https://youtube.com/shorts/FyCuSE3mDcc',
        ),
        CatalogExercise(
          id: 'c_bird_dog_hold',
          name: 'Bird Dog Hold',
          sets: 2,
          repsRange: '10-20s',
          restRange: '1m',
          videoUrl: 'https://youtube.com/shorts/knsOPG88idk',
        ),
      ],
    ),

    // DAY 4 — Rest
    CatalogDay(
      dayNumber: 4,
      title: 'Rest Day',
      workoutType: WorkoutType.rest,
      isRestDay: true,
      exercises: [],
    ),

    // DAY 5 — Full Body
    CatalogDay(
      dayNumber: 5,
      title: 'Full Body',
      workoutType: WorkoutType.fullBody,
      isRestDay: false,
      exercises: [
        CatalogExercise(
          id: 'c_chest_fly_machine',
          name: 'Chest Fly Machine',
          sets: 2,
          repsRange: '6-10',
          restRange: '2-3m',
          tempoNote: tempoNoteSlow,
          videoUrl: 'https://youtu.be/eGjt4lk6g34',
          alternatives: ['push_chest_fly'],
        ),
        CatalogExercise(
          id: 'c_dh_v_grip_cable_row',
          name: 'DH V Grip Cable Row',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/qD1WZ5pSuvk',
          alternatives: ['alt_chest_supported_db_row'],
        ),
        CatalogExercise(
          id: 'c_rear_delt_machine_fly_fb',
          name: 'Rear Delt Machine Fly',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/7tgx6QHB0-A',
          alternatives: ['pull_cable_rear_delt_fly'],
        ),
        CatalogExercise(
          id: 'c_db_bicep_curl',
          name: 'DB Bicep Curl',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/MKWBV29S6c0',
          alternatives: ['pull_cable_hammer_curl'],
        ),
        CatalogExercise(
          id: 'c_db_rdl',
          name: 'DB RDL',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/4-Gq43Y0OK4',
        ),
        CatalogExercise(
          id: 'c_seated_leg_curl',
          name: 'Seated Leg Curl',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtu.be/WGih6WFr3uI',
          alternatives: ['alt_db_leg_curl'],
        ),
        CatalogExercise(
          id: 'c_banded_glute_kick_back',
          name: 'Banded Glute Kick Back',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtu.be/rONpWaNIhE8',
        ),
      ],
    ),

    // DAY 6 — Rest
    CatalogDay(
      dayNumber: 6,
      title: 'Rest Day',
      workoutType: WorkoutType.rest,
      isRestDay: true,
      exercises: [],
    ),

    // DAY 7 — Upper + Calves
    CatalogDay(
      dayNumber: 7,
      title: 'Upper + Calves',
      workoutType: WorkoutType.upperAndCalves,
      isRestDay: false,
      exercises: [
        CatalogExercise(
          id: 'c_incline_chest_press_machine',
          name: 'Incline Chest Press Machine',
          sets: 2,
          repsRange: '6-10',
          restRange: '2-3m',
          tempoNote: tempoNoteSlow,
          videoUrl: 'https://youtube.com/shorts/VXaBbUYMfIs',
          alternatives: ['alt_db_incline_bench_press'],
        ),
        CatalogExercise(
          id: 'c_sa_db_lat_row',
          name: 'SA DB Lat Row',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtu.be/yHqqGd0tXcw',
          alternatives: ['alt_sa_db_row'],
        ),
        CatalogExercise(
          id: 'c_db_kelso_shrugs',
          name: 'DB Kelso Shrugs',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtu.be/zX0c-WIIilk',
        ),
        CatalogExercise(
          id: 'c_scapular_plane_db_lateral_raises_uc',
          name: 'Scapular Plane DB Lateral Raises',
          sets: 2,
          repsRange: '15-25',
          restRange: '1-2m',
          tempoNote: tempoNoteSlow,
          videoUrl: 'https://youtube.com/shorts/czKlnVCSJPM',
          alternatives: ['push_cable_lateral_raises'],
        ),
        CatalogExercise(
          id: 'c_sa_cable_preacher_bicep_curl',
          name: 'SA Cable Preacher Bicep Curl',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/vyP7ggY_baE',
          alternatives: ['pull_sa_db_preacher_bicep_curl'],
        ),
        CatalogExercise(
          id: 'c_sa_triceps_push_down_uc',
          name: 'SA Triceps Push Down',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/w5a5sErWIEw',
          alternatives: ['push_triceps_push_down'],
        ),
        CatalogExercise(
          id: 'c_standing_calf_raises_machine_uc',
          name: 'Standing Calf Raises Machine',
          sets: 3,
          repsRange: '6-10',
          restRange: '2-3m',
          videoUrl: 'https://youtube.com/shorts/95itLfMBG40',
        ),
      ],
    ),

    // DAY 8 — Rest
    CatalogDay(
      dayNumber: 8,
      title: 'Rest Day',
      workoutType: WorkoutType.rest,
      isRestDay: true,
      exercises: [],
    ),
  ];

  @override
  List<CatalogDay> getEightDayRotation() {
    return _eightDayRotation;
  }

  @override
  CatalogDay getDay(int dayNumber) {
    return _eightDayRotation.firstWhere(
      (d) => d.dayNumber == dayNumber,
      orElse: () => _eightDayRotation.first,
    );
  }

  @override
  CatalogDay? getDayByWorkoutType(WorkoutType type) {
    try {
      return _eightDayRotation.firstWhere(
        (d) => d.workoutType == type && !d.isRestDay,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  CatalogExercise? getExerciseById(String id) {
    for (final day in _eightDayRotation) {
      for (final ex in day.exercises) {
        if (ex.id == id) return ex;
      }
    }
    return null;
  }

  @override
  List<CatalogExercise> getAlternatives(String exerciseId) {
    final current = getExerciseById(exerciseId);
    if (current == null) return [];

    final altIds = current.alternatives;
    if (altIds.isEmpty) return [];

    final results = <CatalogExercise>[];
    for (final altId in altIds) {
      final found = getExerciseById(altId);
      if (found != null) {
        results.add(found);
      }
    }
    return results;
  }
}

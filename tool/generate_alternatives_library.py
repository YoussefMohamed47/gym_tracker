"""Generate lib/features/workout/data/datasources/alternatives_library.dart.

Usage: python3 tool/generate_alternatives_library.py lib/features/workout/data/datasources/alternatives_library.dart

Each new exercise gets a form video, rep range and how-to steps from
alternatives_details.py (videos picked from YouTube tutorial results). Alternatives are chosen by movement pattern and target
muscle, mixing equipment so a busy station can always be swapped.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from alternatives_details import DETAILS  # noqa: E402

# id -> (name, weighted)
NEW = {
    # Chest
    'alt_incline_barbell_bench_press': ('Incline Barbell Bench Press', True),
    'alt_barbell_bench_press': ('Barbell Bench Press', True),
    'alt_smith_flat_bench_press': ('Smith Machine Flat Bench Press', True),
    'alt_cable_chest_press': ('Standing Cable Chest Press', True),
    'alt_push_up': ('Push Up', True),
    'alt_db_chest_fly': ('DB Chest Fly', True),
    'alt_mid_cable_crossover': ('Mid Cable Crossover', True),
    'alt_low_to_high_cable_fly': ('Low to High Cable Fly', True),
    'alt_decline_db_press': ('Decline DB Press', True),
    'alt_assisted_chest_dip': ('Assisted Chest Dip Machine', True),
    # Back
    'alt_seated_row_machine': ('Seated Row Machine', True),
    'alt_barbell_bent_over_row': ('Barbell Bent Over Row', True),
    'alt_wide_grip_cable_row': ('Wide Grip Cable Row', True),
    'alt_lat_pulldown': ('Lat Pulldown', True),
    'alt_straight_arm_pulldown': ('Straight Arm Cable Pulldown', True),
    'alt_assisted_pull_up': ('Assisted Pull Up Machine', True),
    # Traps
    'alt_barbell_shrugs': ('Barbell Shrugs', True),
    'alt_smith_shrugs': ('Smith Machine Shrugs', True),
    'alt_cable_kelso_shrug': ('Cable Kelso Shrug', True),
    'alt_chest_supported_kelso_shrug': ('Chest Supported Machine Kelso Shrug', True),
    # Shoulders
    'alt_lateral_raise_machine': ('Lateral Raise Machine', True),
    'alt_lean_away_db_lateral_raise': ('Lean Away DB Lateral Raise', True),
    'alt_cable_y_raise': ('Cable Y Raise', True),
    'alt_reverse_db_fly': ('Reverse DB Fly', True),
    'alt_cable_face_pull': ('Cable Face Pull', True),
    'alt_cable_rear_delt_row': ('Cable Rear Delt Row', True),
    # Biceps
    'alt_bayesian_cable_curl': ('Bayesian Cable Curl', True),
    'alt_ez_bar_curl': ('EZ Bar Curl', True),
    'alt_cable_bicep_curl': ('Cable Bicep Curl', True),
    'alt_db_hammer_curl': ('DB Hammer Curl', True),
    'alt_cross_body_hammer_curl': ('Cross Body Hammer Curl', True),
    'alt_preacher_curl_machine': ('Preacher Curl Machine', True),
    'alt_ez_bar_preacher_curl': ('EZ Bar Preacher Curl', True),
    # Triceps
    'alt_db_skull_crusher': ('DB Skull Crusher', True),
    'alt_close_grip_bench_press': ('Close Grip Bench Press', True),
    'alt_triceps_dip_machine': ('Triceps Dip Machine', True),
    'alt_db_triceps_kickback': ('DB Triceps Kickback', True),
    'alt_cable_overhead_triceps_extension': ('Cable Overhead Triceps Extension', True),
    # Forearms
    'alt_db_wrist_curl': ('DB Wrist Curl', True),
    'alt_barbell_wrist_curl': ('Barbell Wrist Curl', True),
    'alt_db_reverse_wrist_curl': ('DB Reverse Wrist Curl', True),
    # Quads
    'alt_hack_squat_machine': ('Hack Squat Machine', True),
    'alt_smith_squat': ('Smith Machine Squat', True),
    'alt_bulgarian_split_squat': ('DB Bulgarian Split Squat', True),
    'alt_sa_leg_extension': ('Single Leg Extension', True),
    'alt_heel_elevated_goblet_squat': ('Heel Elevated Goblet Squat', True),
    # Adductors
    'alt_cable_hip_adduction': ('Cable Hip Adduction', True),
    'alt_sumo_goblet_squat': ('Sumo Goblet Squat', True),
    'alt_copenhagen_plank': ('Copenhagen Plank', False),
    # Glutes / hamstrings
    'alt_barbell_hip_thrust': ('Barbell Hip Thrust', True),
    'alt_smith_hip_thrust': ('Smith Machine Hip Thrust', True),
    'alt_hip_thrust_machine': ('Hip Thrust Machine', True),
    'alt_glute_bridge': ('Glute Bridge', True),
    'alt_cable_pull_through': ('Cable Pull Through', True),
    'alt_barbell_rdl': ('Barbell RDL', True),
    'alt_smith_rdl': ('Smith Machine RDL', True),
    'alt_single_leg_db_rdl': ('Single Leg DB RDL', True),
    'alt_45_back_extension': ('45° Back Extension', True),
    'alt_lying_leg_curl': ('Lying Leg Curl Machine', True),
    'alt_swiss_ball_leg_curl': ('Swiss Ball Leg Curl', False),
    'alt_cable_glute_kick_back': ('Cable Glute Kick Back', True),
    'alt_glute_kickback_machine': ('Glute Kickback Machine', True),
    # Calves
    'alt_seated_calf_raise_machine': ('Seated Calf Raise Machine', True),
    'alt_smith_calf_raise': ('Smith Machine Calf Raise', True),
    'alt_sa_db_calf_raise': ('Single Leg DB Calf Raise', True),
    # Core / mobility
    'alt_thread_the_needle': ('Thread the Needle', False),
    'alt_plank': ('Plank', False),
    'alt_side_plank': ('Side Plank', False),
}

CHEST_INCLINE = ['alt_db_incline_bench_press', 'c_incline_chest_press_machine',
                 'c_incline_chest_press_smith', 'push_incline_chest_press_machine',
                 'alt_incline_barbell_bench_press', 'alt_low_to_high_cable_fly']
LATERAL = ['push_cable_lateral_raises', 'alt_lateral_raise_machine',
           'alt_lean_away_db_lateral_raise', 'alt_cable_y_raise',
           'c_scapular_plane_db_lateral_raises']
REAR_DELT = ['pull_cable_rear_delt_fly', 'alt_reverse_db_fly', 'alt_cable_face_pull',
             'alt_cable_rear_delt_row', 'c_rear_delt_machine_fly']
TRICEPS = ['push_triceps_push_down', 'push_sa_triceps_over_head_extension',
           'alt_cable_overhead_triceps_extension', 'alt_db_skull_crusher',
           'alt_triceps_dip_machine', 'alt_close_grip_bench_press',
           'alt_db_triceps_kickback', 'c_sa_triceps_push_down']
CURL = ['c_db_bicep_curl', 'c_incline_db_bicep_curl', 'alt_bayesian_cable_curl',
        'alt_cable_bicep_curl', 'alt_ez_bar_curl', 'upper_no_cheat_db_bicep_curl']
CALVES = ['c_standing_calf_raises_machine', 'alt_seated_calf_raise_machine',
          'alt_smith_calf_raise', 'legs_seated_leg_press_calve_raises',
          'alt_sa_db_calf_raise']
LAT_ROW = ['alt_sa_db_row', 'c_sa_db_lat_row', 'c_sa_cable_lat_row',
           'pull_sa_iso_lateral_lat_row', 'alt_lat_pulldown',
           'alt_straight_arm_pulldown', 'pull_sa_lat_pull_down']
ROW = ['alt_chest_supported_db_row', 'c_t_bar_row_machine', 'c_dh_v_grip_cable_row',
       'alt_seated_row_machine', 'alt_wide_grip_cable_row', 'pull_t_bar_row',
       'alt_barbell_bent_over_row']
FLY = ['c_chest_fly_machine', 'c_high_to_low_cable_chest_fly', 'alt_db_chest_fly',
       'alt_mid_cable_crossover', 'push_chest_fly', 'upper_chest_fly_machine']

MAP = {
    # Day 1 · Chest & Back
    'c_incline_chest_press_smith': CHEST_INCLINE,
    'c_db_chest_press': ['alt_db_bench_press', 'push_chest_press_machine',
                         'alt_barbell_bench_press', 'alt_smith_flat_bench_press',
                         'alt_cable_chest_press', 'alt_push_up'],
    'c_high_to_low_cable_chest_fly': FLY + ['alt_decline_db_press',
                                            'alt_assisted_chest_dip'],
    'c_t_bar_row_machine': ROW,
    'c_sa_cable_lat_row': LAT_ROW,
    'c_cable_shrugs': ['pull_db_shrugs', 'alt_barbell_shrugs', 'alt_smith_shrugs',
                       'c_db_kelso_shrugs', 'alt_cable_kelso_shrug'],
    # Day 2 · Shoulder & Arms
    'c_scapular_plane_db_lateral_raises': LATERAL,
    'c_incline_db_bicep_curl': CURL + ['pull_cable_hammer_curl'],
    'c_sa_triceps_push_down': TRICEPS,
    'c_rear_delt_machine_fly': REAR_DELT,
    'c_sa_db_preacher_hammer_curl': ['pull_sa_db_preacher_bicep_curl',
                                     'pull_cable_hammer_curl', 'alt_db_hammer_curl',
                                     'alt_cross_body_hammer_curl',
                                     'alt_preacher_curl_machine', 'upper_reverse_curl'],
    'c_cable_wrist_flexion': ['alt_db_wrist_curl', 'alt_barbell_wrist_curl',
                              'push_forearm_exercise_variations'],
    'c_cable_wrist_extension': ['alt_db_reverse_wrist_curl', 'upper_reverse_curl',
                                'push_forearm_exercise_variations'],
    # Day 3 · Legs
    'c_leg_press_machine': ['alt_hack_squat_machine', 'alt_smith_squat',
                            'alt_goblet_squat', 'alt_bulgarian_split_squat',
                            'legs_body_weighted_squat'],
    'c_leg_extension': ['legs_leg_extension', 'alt_sa_leg_extension',
                        'alt_heel_elevated_goblet_squat', 'alt_goblet_squat'],
    'c_adduction_machine': ['legs_adduction_machine', 'alt_cable_hip_adduction',
                            'alt_banded_adduction', 'alt_sumo_goblet_squat',
                            'alt_copenhagen_plank'],
    'c_db_hip_thrust': ['alt_barbell_hip_thrust', 'alt_smith_hip_thrust',
                        'alt_hip_thrust_machine', 'alt_glute_bridge',
                        'legs_body_weighted_hip_thrust', 'alt_cable_pull_through'],
    'c_standing_calf_raises_machine': [c for c in CALVES
                                       if c != 'c_standing_calf_raises_machine'],
    'c_cat_cow': ['legs_child_pose', 'alt_thread_the_needle', 'routine_trunk_rotation'],
    'c_bird_dog_hold': ['lower_dead_bug', 'alt_plank', 'alt_side_plank',
                        'legs_banded_pallof_twist'],
    # Day 5 · Full Body
    'c_chest_fly_machine': [f for f in FLY if f != 'c_chest_fly_machine'],
    'c_dh_v_grip_cable_row': [r for r in ROW if r != 'c_dh_v_grip_cable_row'],
    'c_rear_delt_machine_fly_fb': REAR_DELT,
    'c_db_bicep_curl': [c for c in CURL if c != 'c_db_bicep_curl']
    + ['pull_cable_hammer_curl'],
    'c_db_rdl': ['alt_barbell_rdl', 'alt_smith_rdl', 'alt_single_leg_db_rdl',
                 'alt_cable_pull_through', 'alt_45_back_extension',
                 'lower_body_weighted_rdl'],
    'c_seated_leg_curl': ['alt_lying_leg_curl', 'lower_seated_leg_curl',
                          'alt_db_leg_curl', 'alt_swiss_ball_leg_curl'],
    'c_banded_glute_kick_back': ['alt_cable_glute_kick_back',
                                 'alt_glute_kickback_machine', 'alt_glute_bridge'],
    # Day 7 · Upper + Calves
    'c_incline_chest_press_machine': CHEST_INCLINE,
    'c_sa_db_lat_row': LAT_ROW,
    'c_db_kelso_shrugs': ['alt_cable_kelso_shrug', 'alt_chest_supported_kelso_shrug',
                          'c_cable_shrugs', 'pull_db_shrugs'],
    'c_scapular_plane_db_lateral_raises_uc': LATERAL,
    'c_sa_cable_preacher_bicep_curl': ['c_sa_db_bench_preacher_curl',
                                       'pull_sa_db_preacher_bicep_curl',
                                       'alt_preacher_curl_machine',
                                       'alt_ez_bar_preacher_curl',
                                       'alt_bayesian_cable_curl'],
    'c_sa_triceps_push_down_uc': TRICEPS,
    'c_standing_calf_raises_machine_uc': CALVES,
}


def dart_str(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


lines = [
    "// GENERATED by tool/generate_alternatives_library.py — edit there, then run:\n// python3 tool/generate_alternatives_library.py lib/features/workout/data/datasources/alternatives_library.dart",
    "import '../../domain/entities/exercise_definition.dart';",
    "",
    "/// More swap options for every exercise in the 8-day plan, chosen by",
    "/// movement and target muscle, across machine, cable, dumbbell, barbell and",
    "/// bodyweight so a busy station can always be replaced.",
    "///",
    "/// Each new exercise has a form video, a rep range and how-to steps.",
    "class AlternativesLibrary {",
    "  AlternativesLibrary._();",
    "",
    "  static const List<ExerciseDefinition> exercises = [",
]
missing = [e for e in NEW if e not in DETAILS]
if missing:
    sys.exit(f"no video/how-to for: {missing}")
for eid, (name, weighted) in NEW.items():
    url, reps, steps = DETAILS[eid]
    lines.append("    ExerciseDefinition(")
    lines.append(f"      id: {dart_str(eid)},")
    lines.append(f"      name: {dart_str(name)},")
    lines.append(f"      videoUrl: {dart_str(url)},")
    if not weighted:
        lines.append("      isWeightAllowed: false,")
    lines.append(f"      repRange: {dart_str(reps)},")
    lines.append("      howTo: [")
    for step in steps:
        lines.append(f"        {dart_str(step)},")
    lines.append("      ],")
    lines.append("    ),")
lines += ["  ];", "", "  /// Planned exercise id -> extra alternatives (in suggested order).",
          "  static const Map<String, List<String>> forExercise = {"]
for key, alts in MAP.items():
    seen = []
    for a in alts:
        if a != key and a not in seen:
            seen.append(a)
    lines.append(f"    {dart_str(key)}: [")
    for a in seen:
        lines.append(f"      {dart_str(a)},")
    lines.append("    ],")
lines += ["  };", "}", ""]

open(sys.argv[1], 'w').write("\n".join(lines))
print("exercises:", len(NEW), "planned exercises covered:", len(MAP))

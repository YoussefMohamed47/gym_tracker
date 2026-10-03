import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_catalog.dart';

void main() {
  group('WorkoutCatalog Regression Tests', () {
    test('Authoritative Schedule Mapping', () {
      // Sunday = Pull
      expect(
        WorkoutCatalog.getWorkoutForDate(DateTime(2026, 8, 23))?.id,
        'pull',
      );
      // Monday = Legs
      expect(
        WorkoutCatalog.getWorkoutForDate(DateTime(2026, 8, 24))?.id,
        'legs',
      );
      // Tuesday = Rest
      expect(WorkoutCatalog.getWorkoutForDate(DateTime(2026, 8, 25)), isNull);
      // Wednesday = Upper
      expect(
        WorkoutCatalog.getWorkoutForDate(DateTime(2026, 8, 26))?.id,
        'upper',
      );
      // Thursday = Lower
      expect(
        WorkoutCatalog.getWorkoutForDate(DateTime(2026, 8, 27))?.id,
        'lower',
      );
      // Friday = Rest
      expect(WorkoutCatalog.getWorkoutForDate(DateTime(2026, 8, 28)), isNull);
      // Saturday = Push
      expect(
        WorkoutCatalog.getWorkoutForDate(DateTime(2026, 8, 29))?.id,
        'push',
      );
    });

    test('PUSH (Saturday) Canonical Content', () {
      final push = WorkoutCatalog.workouts.firstWhere((w) => w.id == 'push');
      expect(push.exercises.length, 6);

      final expectedExercises = [
        'push_chest_press_machine',
        'push_incline_chest_press_machine',
        'push_shoulder_press_machine',
        'push_cable_lateral_raises',
        'push_sa_triceps_over_head_extension',
        'push_triceps_push_down',
      ];

      for (int i = 0; i < expectedExercises.length; i++) {
        expect(push.exercises[i].exerciseId, expectedExercises[i]);
        final def = WorkoutCatalog.getExerciseById(
          push.exercises[i].exerciseId,
        );
        expect(
          def.id,
          isNot('push_chest_fly'),
        ); // Chest Fly must NOT be in Push
      }

      // Verify specific metadata
      final shoulderPress = push.exercises[2];
      expect(shoulderPress.prescribedSets, 2);
      expect(shoulderPress.prescribedRest, '2-3m');
    });

    test('PULL (Sunday) Canonical Content', () {
      final pull = WorkoutCatalog.workouts.firstWhere((w) => w.id == 'pull');
      expect(pull.exercises.length, 7);

      final expectedExercises = [
        'pull_t_bar_row',
        'pull_sa_lat_pull_down',
        'pull_sa_iso_lateral_lat_row',
        'pull_cable_rear_delt_fly',
        'pull_sa_db_preacher_bicep_curl',
        'pull_cable_hammer_curl',
        'pull_db_shrugs',
      ];

      for (int i = 0; i < expectedExercises.length; i++) {
        expect(pull.exercises[i].exerciseId, expectedExercises[i]);
      }

      // Verify Face Pull was replaced by Cable Rear Delt Fly
      expect(
        pull.exercises.any((e) => e.exerciseId.contains('face_pull')),
        isFalse,
      );
    });

    test('LEGS (Monday) Canonical Content', () {
      final legs = WorkoutCatalog.workouts.firstWhere((w) => w.id == 'legs');
      expect(legs.exercises.length, 7);

      expect(legs.exercises[0].exerciseId, 'legs_body_weighted_squat');
      expect(legs.exercises[5].exerciseId, 'legs_child_pose');
      expect(legs.exercises[6].exerciseId, 'legs_banded_pallof_twist');
    });

    test('UPPER (Wednesday) Canonical Content', () {
      final upper = WorkoutCatalog.workouts.firstWhere((w) => w.id == 'upper');
      expect(upper.exercises.length, 7);
      expect(upper.exercises[0].exerciseId, 'upper_chest_fly_machine');
    });

    test('LOWER (Thursday) Canonical Content', () {
      final lower = WorkoutCatalog.workouts.firstWhere((w) => w.id == 'lower');
      expect(lower.exercises.length, 6);
      expect(lower.exercises[1].exerciseId, 'lower_seated_leg_curl');
    });

    test('DAILY ROUTINE Canonical Content', () {
      final routine = WorkoutCatalog.getDailyRoutine();
      expect(routine.exercises.length, 5);
      expect(routine.exercises[0].exerciseId, 'routine_slr');
      expect(routine.exercises[4].exerciseId, 'routine_double_knee_to_chest');
    });

    test('Video URL Mapping Fidelity', () {
      final chestPress = WorkoutCatalog.getExerciseById(
        'push_chest_press_machine',
      );
      expect(
        chestPress.videoUrl,
        'https://youtu.be/vnd-GBtTMLI?si=QpCyy_EEtcNHVN10',
      );

      final tricepPushdown = WorkoutCatalog.getExerciseById(
        'push_triceps_push_down',
      );
      expect(
        tricepPushdown.videoUrl,
        'https://youtube.com/shorts/WjLJ7zIppXQ?si=2F4GVDQYVmElNolD',
      );
    });

    test('Upper Body Warm-up Routine Canonical Content & Isolation', () {
      final warmup = WorkoutCatalog.getUpperBodyWarmup();
      expect(warmup.exercises.length, 4);

      expect(warmup.exercises[0].exerciseId, 'warmup_banded_shoulder_circles');
      expect(warmup.exercises[0].prescribedSets, 1);
      expect(warmup.exercises[0].prescribedReps, '10–12');

      expect(warmup.exercises[1].exerciseId, 'warmup_banded_external_rotation');
      expect(warmup.exercises[1].prescribedSets, 2);
      expect(warmup.exercises[1].prescribedReps, '12–15 / arm');

      expect(warmup.exercises[2].exerciseId, 'warmup_banded_scapula_push_up');
      expect(warmup.exercises[2].prescribedSets, 1);
      expect(warmup.exercises[2].prescribedReps, '10–12');

      expect(warmup.exercises[3].exerciseId, 'warmup_banded_single_arm_row');
      expect(warmup.exercises[3].prescribedSets, 2);
      expect(warmup.exercises[3].prescribedReps, '12 / arm');

      // Verify excluded exercises are NOT included in warmup
      for (final slot in warmup.exercises) {
        final name = WorkoutCatalog.getExerciseById(slot.exerciseId).name.toLowerCase();
        expect(name.contains('shoulder dislocates'), isFalse);
        expect(name.contains('upright row'), isFalse);
        expect(name.contains('strict press'), isFalse);
      }

      // Verify video URLs exist for all warmup exercises
      for (final slot in warmup.exercises) {
        final def = WorkoutCatalog.getExerciseById(slot.exerciseId);
        expect(def.videoUrl, isNotNull);
        expect(def.videoUrl, contains('youtube.com/shorts/'));
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/data/repositories/workout_catalog_repository_impl.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';

void main() {
  late WorkoutCatalogRepositoryImpl repository;

  setUp(() {
    repository = WorkoutCatalogRepositoryImpl();
  });

  group('WorkoutCatalogRepositoryImpl - 8-Day Rotation Tests', () {
    test('getEightDayRotation returns exactly 8 days in sequence', () {
      final days = repository.getEightDayRotation();
      expect(days.length, 8);

      expect(days[0].dayNumber, 1);
      expect(days[0].title, 'Chest & Back');
      expect(days[0].workoutType, WorkoutType.chestAndBack);
      expect(days[0].isRestDay, isFalse);

      expect(days[1].dayNumber, 2);
      expect(days[1].title, 'Shoulder & Arms');
      expect(days[1].workoutType, WorkoutType.shoulderAndArms);
      expect(days[1].isRestDay, isFalse);

      expect(days[2].dayNumber, 3);
      expect(days[2].title, 'Legs');
      expect(days[2].workoutType, WorkoutType.legs);
      expect(days[2].isRestDay, isFalse);

      expect(days[3].dayNumber, 4);
      expect(days[3].title, 'Rest Day');
      expect(days[3].workoutType, WorkoutType.rest);
      expect(days[3].isRestDay, isTrue);

      expect(days[4].dayNumber, 5);
      expect(days[4].title, 'Full Body');
      expect(days[4].workoutType, WorkoutType.fullBody);
      expect(days[4].isRestDay, isFalse);

      expect(days[5].dayNumber, 6);
      expect(days[5].title, 'Rest Day');
      expect(days[5].workoutType, WorkoutType.rest);
      expect(days[5].isRestDay, isTrue);

      expect(days[6].dayNumber, 7);
      expect(days[6].title, 'Upper + Calves');
      expect(days[6].workoutType, WorkoutType.upperAndCalves);
      expect(days[6].isRestDay, isFalse);

      expect(days[7].dayNumber, 8);
      expect(days[7].title, 'Rest Day');
      expect(days[7].workoutType, WorkoutType.rest);
      expect(days[7].isRestDay, isTrue);
    });

    test('Day 1 (Chest & Back) contains 6 prescribed exercises with video links', () {
      final day = repository.getDay(1);
      expect(day.exercises.length, 6);

      final exerciseNames = day.exercises.map((e) => e.name).toList();
      expect(exerciseNames, [
        'Incline Chest Press Smith Machine',
        'DB Chest Press',
        'High to Low Cable Chest Fly',
        'T-Bar Row Machine',
        'SA Cable Lat Row',
        'Cable Shrugs',
      ]);

      // Verify tempo notes on first 3 exercises
      expect(day.exercises[0].tempoNote, 'Light weight, slow tempo');
      expect(day.exercises[1].tempoNote, 'Light weight, slow tempo');
      expect(day.exercises[2].tempoNote, 'Light weight, slow tempo');
      expect(day.exercises[3].tempoNote, isNull);

      // Verify all exercises have valid video URLs
      for (final ex in day.exercises) {
        expect(ex.videoUrl, isNotNull);
        expect(ex.videoUrl, contains('youtu'));
      }
    });

    test('Day 2 (Shoulder & Arms) handles superset video URLs for Forearms', () {
      final day = repository.getDay(2);
      expect(day.exercises.length, 6);

      final forearmSuperset = day.exercises.firstWhere(
        (e) => e.id == 'c_cable_wrist_flexion_extension',
      );
      expect(forearmSuperset.name, 'Cable Wrist Flexion + Cable Wrist Extension');
      expect(forearmSuperset.videoUrl, contains('youtu.be/WVAaKJvToe0'));
      expect(forearmSuperset.pairedVideoUrls, isNotNull);
      expect(forearmSuperset.pairedVideoUrls!.first, contains('youtube.com/shorts/_JiYn7I9F_k'));
    });

    test('Day 3 (Legs) contains 7 prescribed exercises', () {
      final day = repository.getDay(3);
      expect(day.exercises.length, 7);

      expect(day.exercises[0].name, 'Leg Press Machine');
      expect(day.exercises[1].name, 'Leg Extension');
      expect(day.exercises[2].name, 'Adduction Machine');
      expect(day.exercises[3].name, 'DB Hip Thrust');
      expect(day.exercises[4].name, 'Standing Calf Raises Machine');
      expect(day.exercises[5].name, 'Cat Cow');
      expect(day.exercises[6].name, 'Bird Dog Hold');
    });

    test('Day 5 (Full Body) contains 7 prescribed exercises', () {
      final day = repository.getDay(5);
      expect(day.exercises.length, 7);

      expect(day.exercises[0].name, 'Chest Fly Machine');
      expect(day.exercises[0].tempoNote, 'Light weight, slow tempo');
      expect(day.exercises[1].name, 'DH V Grip Cable Row');
      expect(day.exercises[2].name, 'Rear Delt Machine Fly');
      expect(day.exercises[3].name, 'DB Bicep Curl');
      expect(day.exercises[4].name, 'DB RDL');
      expect(day.exercises[5].name, 'Seated Leg Curl');
      expect(day.exercises[6].name, 'Banded Glute Kick Back');
    });

    test('Day 7 (Upper + Calves) contains 7 prescribed exercises', () {
      final day = repository.getDay(7);
      expect(day.exercises.length, 7);

      expect(day.exercises[0].name, 'Incline Chest Press Machine');
      expect(day.exercises[0].tempoNote, 'Light weight, slow tempo');
      expect(day.exercises[1].name, 'SA DB Lat Row');
      expect(day.exercises[2].name, 'DB Kelso Shrugs');
      expect(day.exercises[3].name, 'Scapular Plane DB Lateral Raises');
      expect(day.exercises[3].tempoNote, 'Light weight, slow tempo');
      expect(day.exercises[4].name, 'SA Cable Preacher Bicep Curl');
      expect(day.exercises[5].name, 'SA Triceps Push Down');
      expect(day.exercises[6].name, 'Standing Calf Raises Machine');
    });

    test('Rest days have empty exercises list', () {
      for (final dayNum in [4, 6, 8]) {
        final day = repository.getDay(dayNum);
        expect(day.isRestDay, isTrue);
        expect(day.exercises, isEmpty);
      }
    });

    test('getDayByWorkoutType resolves correctly for all 8-day rotation types', () {
      final chestAndBack = repository.getDayByWorkoutType(WorkoutType.chestAndBack);
      expect(chestAndBack?.dayNumber, 1);

      final shoulderAndArms = repository.getDayByWorkoutType(WorkoutType.shoulderAndArms);
      expect(shoulderAndArms?.dayNumber, 2);

      final legs = repository.getDayByWorkoutType(WorkoutType.legs);
      expect(legs?.dayNumber, 3);

      final fullBody = repository.getDayByWorkoutType(WorkoutType.fullBody);
      expect(fullBody?.dayNumber, 5);

      final upperAndCalves = repository.getDayByWorkoutType(WorkoutType.upperAndCalves);
      expect(upperAndCalves?.dayNumber, 7);
    });
  });
}

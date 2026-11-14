import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_catalog.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';

void main() {
  test('projects forward through the 8-day rotation', () {
    // Day 1 Chest & Back → day 4 is the first rest day.
    expect(
      WorkoutCatalog.projectedType(WorkoutType.chestAndBack, 1),
      WorkoutType.shoulderAndArms,
    );
    expect(
      WorkoutCatalog.projectedType(WorkoutType.chestAndBack, 3),
      WorkoutType.rest,
    );
  });

  test('projects backward and wraps around the cycle', () {
    expect(
      WorkoutCatalog.projectedType(WorkoutType.chestAndBack, -1),
      WorkoutType.rest,
    );
    expect(
      WorkoutCatalog.projectedType(WorkoutType.chestAndBack, -2),
      WorkoutType.upperAndCalves,
    );
    expect(
      WorkoutCatalog.projectedType(WorkoutType.chestAndBack, 8),
      WorkoutType.chestAndBack,
    );
  });

  test('cannot tell from a rest day or an old-plan day', () {
    expect(WorkoutCatalog.projectedType(WorkoutType.rest, 1), isNull);
    expect(WorkoutCatalog.projectedType(WorkoutType.push, 1), isNull);
  });
}

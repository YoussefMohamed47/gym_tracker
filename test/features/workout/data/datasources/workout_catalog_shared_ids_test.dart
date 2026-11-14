import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/alternatives_library.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_catalog.dart';

void main() {
  test('every pair of same-named exercises shares one history ID', () {
    final byName = <String, Set<String>>{};
    for (final e in [
      ...WorkoutCatalog.exercises,
      ...AlternativesLibrary.exercises,
    ]) {
      byName.putIfAbsent(e.name.trim().toLowerCase(), () => {}).add(e.id);
    }

    for (final MapEntry(key: name, value: ids) in byName.entries) {
      final shared = ids.map(WorkoutCatalog.sharedExerciseId).toSet();
      expect(
        shared,
        hasLength(1),
        reason:
            '"$name" is planned as $ids: add them to '
            'WorkoutCatalog._sameExerciseAs so their history is shared',
      );
    }
  });
}

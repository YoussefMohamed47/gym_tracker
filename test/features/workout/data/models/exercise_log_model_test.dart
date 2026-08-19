import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/data/models/exercise_log_model.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';

void main() {
  group('ExerciseLogModel', () {
    final timestamp = DateTime(2026, 8, 19);

    test('should parse V2 JSON with sets correctly', () {
      final json = {
        'plannedExerciseId': 'ex1',
        'performedExerciseId': 'ex1',
        'sets': [
          {'weightKg': 50.0, 'isPerformed': true},
          {'weightKg': 52.5, 'isPerformed': true},
        ],
        'timestamp': timestamp.toIso8601String(),
      };

      final model = ExerciseLogModel.fromJson(json);

      expect(model.plannedExerciseId, 'ex1');
      expect(model.sets.length, 2);
      expect(model.sets[0].weightKg, 50.0);
      expect(model.sets[1].weightKg, 52.5);
      expect(model.sets[0].isPerformed, true);
    });

    test('should parse V1 legacy JSON correctly', () {
      final json = {
        'plannedExerciseId': 'ex1',
        'performedExerciseId': 'ex1',
        'weightKg': 45.0,
        'isPerformed': true,
        'timestamp': timestamp.toIso8601String(),
      };

      final model = ExerciseLogModel.fromJson(json);

      expect(model.plannedExerciseId, 'ex1');
      expect(model.sets, isEmpty);
      expect(model.weightKg, 45.0);
      expect(model.isPerformed, true);
    });

    test('should serialize to JSON with sets', () {
      final model = ExerciseLogModel(
        plannedExerciseId: 'ex1',
        performedExerciseId: 'ex1',
        sets: const [
          ExerciseSetLog(weightKg: 60.0, isPerformed: true),
          ExerciseSetLog(weightKg: 65.0, isPerformed: false),
        ],
        timestamp: timestamp,
      );

      final json = model.toJson();

      expect(json['sets'], isA<List>());
      final sets = json['sets'] as List;
      expect(sets[0]['weightKg'], 60.0);
      expect(sets[1]['weightKg'], 65.0);
      expect(sets[0]['isPerformed'], true);
      expect(sets[1]['isPerformed'], false);
    });
  });
}

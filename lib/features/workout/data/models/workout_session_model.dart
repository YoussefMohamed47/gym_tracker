import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_type.dart';
import 'exercise_log_model.dart';

class WorkoutSessionModel extends WorkoutSession {
  const WorkoutSessionModel({
    required super.dateKey,
    required super.workoutType,
    required super.exerciseLogs,
    required super.displayUnit,
  });

  factory WorkoutSessionModel.fromJson(
    String dateKey,
    Map<String, dynamic> json,
  ) {
    final logsJson = json['exerciseLogs'] as Map<String, dynamic>;
    final logs = logsJson.map(
      (key, value) => MapEntry(
        key,
        ExerciseLogModel.fromJson(value as Map<String, dynamic>),
      ),
    );

    return WorkoutSessionModel(
      dateKey: dateKey,
      workoutType: WorkoutType.values.firstWhere(
        (e) => e.name == json['workoutType'],
      ),
      exerciseLogs: logs,
      displayUnit: WeightUnit.values.firstWhere(
        (e) => e.name == (json['displayUnit'] as String? ?? 'kg'),
        orElse: () => WeightUnit.kg,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workoutType': workoutType.name,
      'displayUnit': displayUnit.name,
      'exerciseLogs': exerciseLogs.map(
        (key, value) =>
            MapEntry(key, ExerciseLogModel.fromEntity(value).toJson()),
      ),
    };
  }

  factory WorkoutSessionModel.fromEntity(WorkoutSession entity) {
    return WorkoutSessionModel(
      dateKey: entity.dateKey,
      workoutType: entity.workoutType,
      exerciseLogs: entity.exerciseLogs,
      displayUnit: entity.displayUnit,
    );
  }
}

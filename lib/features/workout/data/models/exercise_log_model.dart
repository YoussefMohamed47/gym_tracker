import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_log.dart';
import 'exercise_set_log_model.dart';

class ExerciseLogModel extends ExerciseLog {
  const ExerciseLogModel({
    required super.plannedExerciseId,
    required super.performedExerciseId,
    super.sets,
    super.weightKg,
    super.isPerformed,
    super.imagePath,
    required super.timestamp,
    super.displayUnit,
  });

  factory ExerciseLogModel.fromJson(Map<String, dynamic> json) {
    final displayUnit = WeightUnit.values.firstWhere(
      (e) => e.name == (json['displayUnit'] as String? ?? 'kg'),
      orElse: () => WeightUnit.kg,
    );

    // Check if it's V2 (has 'sets' key)
    if (json.containsKey('sets') && json['sets'] != null) {
      final setsJson = json['sets'] as List<dynamic>;
      return ExerciseLogModel(
        plannedExerciseId: json['plannedExerciseId'] as String,
        performedExerciseId: json['performedExerciseId'] as String,
        sets: setsJson
            .map((s) => ExerciseSetLogModel.fromJson(s as Map<String, dynamic>))
            .toList(),
        imagePath: json['imagePath'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        displayUnit: displayUnit,
      );
    }

    // Legacy V1: Map single values
    return ExerciseLogModel(
      plannedExerciseId: json['plannedExerciseId'] as String,
      performedExerciseId: json['performedExerciseId'] as String,
      sets: const [],
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      isPerformed: json['isPerformed'] as bool? ?? false,
      imagePath: json['imagePath'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      displayUnit: displayUnit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plannedExerciseId': plannedExerciseId,
      'performedExerciseId': performedExerciseId,
      'sets': sets
          .map((s) => ExerciseSetLogModel.fromEntity(s).toJson())
          .toList(),
      'weightKg': weightKg,
      'isPerformed': isPerformed,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'displayUnit': displayUnit.name,
    };
  }

  factory ExerciseLogModel.fromEntity(ExerciseLog entity) {
    return ExerciseLogModel(
      plannedExerciseId: entity.plannedExerciseId,
      performedExerciseId: entity.performedExerciseId,
      sets: entity.sets,
      weightKg: entity.weightKg,
      isPerformed: entity.isPerformed,
      imagePath: entity.imagePath,
      timestamp: entity.timestamp,
      displayUnit: entity.displayUnit,
    );
  }
}

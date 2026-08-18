import '../../domain/entities/exercise_log.dart';

class ExerciseLogModel extends ExerciseLog {
  const ExerciseLogModel({
    required super.plannedExerciseId,
    required super.performedExerciseId,
    super.weightKg,
    super.isPerformed,
    super.imagePath,
    required super.timestamp,
  });

  factory ExerciseLogModel.fromJson(Map<String, dynamic> json) {
    return ExerciseLogModel(
      plannedExerciseId: json['plannedExerciseId'] as String,
      performedExerciseId: json['performedExerciseId'] as String,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      isPerformed: json['isPerformed'] as bool? ?? false,
      imagePath: json['imagePath'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plannedExerciseId': plannedExerciseId,
      'performedExerciseId': performedExerciseId,
      'weightKg': weightKg,
      'isPerformed': isPerformed,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExerciseLogModel.fromEntity(ExerciseLog entity) {
    return ExerciseLogModel(
      plannedExerciseId: entity.plannedExerciseId,
      performedExerciseId: entity.performedExerciseId,
      weightKg: entity.weightKg,
      isPerformed: entity.isPerformed,
      imagePath: entity.imagePath,
      timestamp: entity.timestamp,
    );
  }
}

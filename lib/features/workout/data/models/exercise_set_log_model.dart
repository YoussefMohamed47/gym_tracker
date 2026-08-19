import '../../domain/entities/exercise_set_log.dart';

class ExerciseSetLogModel extends ExerciseSetLog {
  const ExerciseSetLogModel({super.weightKg, super.isPerformed});

  factory ExerciseSetLogModel.fromJson(Map<String, dynamic> json) {
    return ExerciseSetLogModel(
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      isPerformed: json['isPerformed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'weightKg': weightKg, 'isPerformed': isPerformed};
  }

  factory ExerciseSetLogModel.fromEntity(ExerciseSetLog entity) {
    return ExerciseSetLogModel(
      weightKg: entity.weightKg,
      isPerformed: entity.isPerformed,
    );
  }
}

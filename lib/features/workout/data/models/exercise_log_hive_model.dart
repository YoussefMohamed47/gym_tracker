import 'package:hive_ce/hive.dart';
import 'exercise_set_log_hive_model.dart';

part 'exercise_log_hive_model.g.dart';

@HiveType(typeId: 2)
class ExerciseLogHiveModel extends HiveObject {
  @HiveField(0)
  final String plannedExerciseId;

  @HiveField(1)
  final String performedExerciseId;

  @HiveField(2)
  final List<ExerciseSetLogHiveModel> sets;

  @HiveField(3)
  final double? weightKg;

  @HiveField(4)
  final bool isPerformed;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final String displayUnit;

  ExerciseLogHiveModel({
    required this.plannedExerciseId,
    required this.performedExerciseId,
    required this.sets,
    this.weightKg,
    required this.isPerformed,
    this.imagePath,
    required this.timestamp,
    required this.displayUnit,
  });
}

import 'package:hive_ce/hive.dart';

part 'exercise_set_log_hive_model.g.dart';

@HiveType(typeId: 3)
class ExerciseSetLogHiveModel extends HiveObject {
  @HiveField(0)
  final int setIndex;

  @HiveField(1)
  final double weightKg;

  @HiveField(2)
  final bool isPerformed;

  @HiveField(3)
  final int? actualReps;

  ExerciseSetLogHiveModel({
    required this.setIndex,
    required this.weightKg,
    required this.isPerformed,
    this.actualReps,
  });
}

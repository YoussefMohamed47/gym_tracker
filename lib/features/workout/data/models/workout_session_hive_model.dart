import 'package:hive_ce/hive.dart';
import 'exercise_log_hive_model.dart';

part 'workout_session_hive_model.g.dart';

@HiveType(typeId: 1)
class WorkoutSessionHiveModel extends HiveObject {
  @HiveField(0)
  final String dateKey;

  @HiveField(1)
  final String workoutType;

  @HiveField(2)
  final List<ExerciseLogHiveModel> exerciseLogs;

  @HiveField(3)
  final String displayUnit;

  WorkoutSessionHiveModel({
    required this.dateKey,
    required this.workoutType,
    required this.exerciseLogs,
    required this.displayUnit,
  });
}

import 'package:hive_ce/hive.dart';

part 'daily_report_hive_model.g.dart';

@HiveType(typeId: 0)
class DailyReportHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String breakfast;

  @HiveField(2)
  final String lunch;

  @HiveField(3)
  final String snack;

  @HiveField(4)
  final String beforeTraining;

  @HiveField(5)
  final String afterTraining;

  @HiveField(6)
  final String dinner;

  @HiveField(7)
  final String water;

  @HiveField(8)
  final String training;

  @HiveField(9)
  final String cardio;

  @HiveField(10)
  final String supplements;

  @HiveField(11)
  final String sleepTime;

  @HiveField(12)
  final String? notes;

  @HiveField(13)
  final DateTime? dateTime;

  @HiveField(14)
  final String? imagePath;

  DailyReportHiveModel({
    required this.id,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.beforeTraining,
    required this.afterTraining,
    required this.dinner,
    required this.water,
    required this.training,
    required this.cardio,
    required this.supplements,
    required this.sleepTime,
    this.notes,
    this.dateTime,
    this.imagePath,
  });
}

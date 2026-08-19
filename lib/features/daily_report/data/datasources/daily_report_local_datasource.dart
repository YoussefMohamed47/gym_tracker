import 'package:hive_ce/hive.dart';
import '../models/daily_report_hive_model.dart';
import '../../domain/model/daily_report.dart';

abstract class DailyReportLocalDataSource {
  Future<void> saveReport(DailyReport report);
  Future<List<DailyReport>> getReportHistory();
  Future<void> deleteReport(String id);
}

class HiveDailyReportLocalDataSource implements DailyReportLocalDataSource {
  final Box<DailyReportHiveModel> _box;

  HiveDailyReportLocalDataSource(this._box);

  @override
  Future<void> saveReport(DailyReport report) async {
    await _box.put(report.id, _toHiveModel(report));
  }

  @override
  Future<List<DailyReport>> getReportHistory() async {
    final reports = _box.values.map(_fromHiveModel).toList();
    // Sort newest first
    reports.sort((a, b) {
      if (a.dateTime == null && b.dateTime == null) return 0;
      if (a.dateTime == null) return 1;
      if (b.dateTime == null) return -1;
      return b.dateTime!.compareTo(a.dateTime!);
    });
    return reports;
  }

  @override
  Future<void> deleteReport(String id) async {
    await _box.delete(id);
  }

  DailyReportHiveModel _toHiveModel(DailyReport report) {
    return DailyReportHiveModel(
      id: report.id,
      breakfast: report.breakfast,
      lunch: report.lunch,
      snack: report.snack,
      beforeTraining: report.beforeTraining,
      afterTraining: report.afterTraining,
      dinner: report.dinner,
      water: report.water,
      training: report.training,
      cardio: report.cardio,
      supplements: report.supplements,
      sleepTime: report.sleepTime,
      notes: report.notes,
      dateTime: report.dateTime,
      imagePath: report.imagePath,
    );
  }

  DailyReport _fromHiveModel(DailyReportHiveModel model) {
    return DailyReport(
      id: model.id,
      breakfast: model.breakfast,
      lunch: model.lunch,
      snack: model.snack,
      beforeTraining: model.beforeTraining,
      afterTraining: model.afterTraining,
      dinner: model.dinner,
      water: model.water,
      training: model.training,
      cardio: model.cardio,
      supplements: model.supplements,
      sleepTime: model.sleepTime,
      notes: model.notes,
      dateTime: model.dateTime,
      imagePath: model.imagePath,
    );
  }
}

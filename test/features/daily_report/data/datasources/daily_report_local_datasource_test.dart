import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:gym_tracker_report/features/daily_report/data/datasources/daily_report_local_datasource.dart';
import 'package:gym_tracker_report/features/daily_report/data/models/daily_report_hive_model.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/core/storage/hive/hive_registrar.dart';
import 'package:gym_tracker_report/core/storage/hive/hive_boxes.dart';

void main() {
  late Directory tempDir;
  late HiveDailyReportLocalDataSource dataSource;
  late Box<DailyReportHiveModel> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('daily_report_ds_test');
    Hive.init(tempDir.path);
    try {
      HiveRegistrar.registerAdapters();
    } catch (_) {}

    box = await Hive.openBox<DailyReportHiveModel>(HiveBoxes.dailyReports);
    dataSource = HiveDailyReportLocalDataSource(box);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HiveDailyReportLocalDataSource Tests', () {
    test('Save and retrieve report', () async {
      final report = DailyReport.empty().copyWith(id: '1', breakfast: 'Oats');

      await dataSource.saveReport(report);
      final history = await dataSource.getReportHistory();

      expect(history.length, 1);
      expect(history.first.id, '1');
      expect(history.first.breakfast, 'Oats');
    });

    test('Delete report', () async {
      final report = DailyReport.empty().copyWith(id: '1');
      await dataSource.saveReport(report);

      await dataSource.deleteReport('1');
      final history = await dataSource.getReportHistory();

      expect(history.isEmpty, true);
    });
  });
}

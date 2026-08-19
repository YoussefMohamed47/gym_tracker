import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'hive_boxes.dart';
import 'hive_registrar.dart';
import 'models/app_settings_hive_model.dart';
import 'models/migration_meta_hive_model.dart';
import '../../../features/daily_report/data/models/daily_report_hive_model.dart';
import '../../../features/workout/data/models/workout_session_hive_model.dart';

class HiveLocalStorage {
  Future<void> init() async {
    await Hive.initFlutter();
    HiveRegistrar.registerAdapters();

    // Open boxes with explicit types to prevent "already open with Box<dynamic>" errors
    await Hive.openBox<DailyReportHiveModel>(HiveBoxes.dailyReports);
    await Hive.openBox<WorkoutSessionHiveModel>(HiveBoxes.workoutSessions);
    await Hive.openBox<AppSettingsHiveModel>(HiveBoxes.settings);
    await Hive.openBox<MigrationMetaHiveModel>(HiveBoxes.migrationMeta);
  }

  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }
}

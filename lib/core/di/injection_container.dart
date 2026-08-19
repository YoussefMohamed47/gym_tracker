import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/hive/hive_local_storage.dart';
import '../storage/hive/hive_boxes.dart';
import '../storage/migration/legacy_persistence_migrator.dart';
import '../storage/migration/media_migrator.dart';
import '../../features/daily_report/data/repository/daily_report_repository_impl.dart';
import '../../features/daily_report/data/service/image_service.dart';
import '../../features/daily_report/data/datasources/daily_report_local_datasource.dart';
import '../../features/daily_report/domain/repository/daily_report_repository.dart';
import '../../features/daily_report/presentation/cubit/daily_report_cubit.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/workout/presentation/cubit/workout_cubit.dart';
import '../../features/workout/data/datasources/workout_local_datasource.dart';
import '../../features/workout/data/repositories/workout_repository_impl.dart';
import '../../features/workout/domain/repositories/workout_repository.dart';
import '../../features/workout/domain/usecases/get_previous_exercise_log.dart';
import '../../features/workout/domain/usecases/get_workout_for_date.dart';
import '../../features/workout/domain/usecases/save_workout_session.dart';
import '../../features/workout/domain/usecases/get_exercise_history.dart';
import '../../features/daily_report/data/models/daily_report_hive_model.dart';
import '../../features/workout/data/models/workout_session_hive_model.dart';
import '../storage/hive/models/app_settings_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final hiveStorage = HiveLocalStorage();
  await hiveStorage.init();
  sl.registerLazySingleton(() => hiveStorage);

  final appDocsDir = await getApplicationDocumentsDirectory();
  sl.registerLazySingleton(() => MediaMigrator(appDocsDir: appDocsDir));

  sl.registerLazySingleton(
    () => LegacyPersistenceMigrator(
      prefs: sl(),
      mediaMigrator: sl(),
      hiveStorage: sl(),
    ),
  );

  // Features - Daily Report & History

  // Cubits
  sl.registerLazySingleton(() => DailyReportCubit(sl()));
  sl.registerFactory(() => HistoryCubit(sl()));
  sl.registerFactory(() => WorkoutCubit(repository: sl()));

  // Repositories
  sl.registerLazySingleton<DailyReportRepository>(
    () => DailyReportRepositoryImpl(imageService: sl(), localDataSource: sl()),
  );

  // Data sources / Services
  sl.registerLazySingleton(() => ImageService());
  sl.registerLazySingleton<DailyReportLocalDataSource>(
    () => HiveDailyReportLocalDataSource(
      sl<HiveLocalStorage>().getBox<DailyReportHiveModel>(
        HiveBoxes.dailyReports,
      ),
    ),
  );

  // Features - Workout
  // Data sources
  sl.registerLazySingleton<WorkoutLocalDataSource>(
    () => WorkoutLocalDataSourceImpl(
      sessionBox: sl<HiveLocalStorage>().getBox<WorkoutSessionHiveModel>(
        HiveBoxes.workoutSessions,
      ),
      settingsBox: sl<HiveLocalStorage>().getBox<AppSettingsHiveModel>(
        HiveBoxes.settings,
      ),
    ),
  );

  // Repositories
  sl.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWorkoutForDate(sl()));
  sl.registerLazySingleton(() => SaveWorkoutSession(sl()));
  sl.registerLazySingleton(() => GetPreviousExerciseLog(sl()));
  sl.registerLazySingleton(() => GetExerciseHistory(sl()));
}

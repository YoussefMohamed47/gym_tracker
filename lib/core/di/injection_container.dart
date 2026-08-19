import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/daily_report/data/repository/daily_report_repository_impl.dart';
import '../../features/daily_report/data/service/image_service.dart';
import '../../features/daily_report/data/service/local_data_source.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

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
  sl.registerLazySingleton(() => LocalDataSource(sl()));

  // Features - Workout
  // Data sources
  sl.registerLazySingleton<WorkoutLocalDataSource>(
    () => WorkoutLocalDataSourceImpl(sharedPreferences: sl()),
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

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/daily_report/data/repository/daily_report_repository_impl.dart';
import '../../features/daily_report/data/service/image_service.dart';
import '../../features/daily_report/data/service/local_data_source.dart';
import '../../features/daily_report/domain/repository/daily_report_repository.dart';
import '../../features/daily_report/presentation/cubit/daily_report_cubit.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Features - Daily Report & History
  
  // Cubits
  sl.registerLazySingleton(() => DailyReportCubit(sl()));
  sl.registerFactory(() => HistoryCubit(sl()));

  // Repositories
  sl.registerLazySingleton<DailyReportRepository>(
    () => DailyReportRepositoryImpl(
      imageService: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources / Services
  sl.registerLazySingleton(() => ImageService());
  sl.registerLazySingleton(() => LocalDataSource(sl()));
}

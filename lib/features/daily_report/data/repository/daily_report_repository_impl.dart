import 'dart:typed_data';
import '../../../../core/error/api_result.dart';
import '../../domain/model/daily_report.dart';
import '../../domain/repository/daily_report_repository.dart';
import '../service/image_service.dart';
import '../service/local_data_source.dart';

class DailyReportRepositoryImpl implements DailyReportRepository {
  final ImageService imageService;
  final LocalDataSource localDataSource;

  DailyReportRepositoryImpl({
    required this.imageService,
    required this.localDataSource,
  });

  @override
  Future<ApiResult<String>> cacheReportImage(Uint8List imageBytes) async {
    try {
      final path = await imageService.saveImageToCache(imageBytes);
      return ApiSuccess(path);
    } catch (e) {
      return const ApiFailure(CacheFailure('Failed to cache image'));
    }
  }

  @override
  Future<ApiResult<DailyReport>> saveReport(DailyReport report) async {
    try {
      await localDataSource.saveReport(report);
      return ApiSuccess(report);
    } catch (e) {
      return const ApiFailure(CacheFailure('Failed to save report'));
    }
  }

  @override
  Future<ApiResult<List<DailyReport>>> getReportHistory() async {
    try {
      final history = await localDataSource.getReportHistory();
      return ApiSuccess(history);
    } catch (e) {
      return const ApiFailure(CacheFailure('Failed to load history'));
    }
  }

  @override
  Future<ApiResult<void>> deleteReport(String id) async {
    try {
      await localDataSource.deleteReport(id);
      return const ApiSuccess(null);
    } catch (e) {
      return const ApiFailure(CacheFailure('Failed to delete report'));
    }
  }
}

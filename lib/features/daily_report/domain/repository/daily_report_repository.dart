import 'dart:typed_data';
import '../../../../core/error/api_result.dart';
import '../model/daily_report.dart';

abstract class DailyReportRepository {
  Future<ApiResult<String>> cacheReportImage(Uint8List imageBytes);
  Future<ApiResult<DailyReport>> saveReport(DailyReport report);
  Future<ApiResult<List<DailyReport>>> getReportHistory();
  Future<ApiResult<void>> deleteReport(String id);
}

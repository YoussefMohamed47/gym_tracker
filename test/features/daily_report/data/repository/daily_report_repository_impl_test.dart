import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/error/api_result.dart';
import 'package:gym_tracker_report/features/daily_report/data/datasources/daily_report_local_datasource.dart';
import 'package:gym_tracker_report/features/daily_report/data/repository/daily_report_repository_impl.dart';
import 'package:gym_tracker_report/features/daily_report/data/service/image_service.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:mocktail/mocktail.dart';

class MockImageService extends Mock implements ImageService {}

class MockLocalDataSource extends Mock implements DailyReportLocalDataSource {}

void main() {
  late DailyReportRepositoryImpl repository;
  late MockImageService mockImageService;
  late MockLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(DailyReport.empty());
  });

  setUp(() {
    mockImageService = MockImageService();
    mockLocalDataSource = MockLocalDataSource();
    repository = DailyReportRepositoryImpl(
      imageService: mockImageService,
      localDataSource: mockLocalDataSource,
    );
  });

  group('cacheReportImage', () {
    final tBytes = Uint8List(10);
    const tPath = 'path/to/image.png';

    test(
      'should return ApiSuccess with path when image service saves successfully',
      () async {
        // arrange
        when(
          () => mockImageService.saveImageToCache(any()),
        ).thenAnswer((_) async => tPath);
        // act
        final result = await repository.cacheReportImage(tBytes);
        // assert
        expect(result, const ApiSuccess(tPath));
        verify(() => mockImageService.saveImageToCache(tBytes));
      },
    );

    test('should return ApiFailure when image service throws', () async {
      // arrange
      when(
        () => mockImageService.saveImageToCache(any()),
      ).thenThrow(Exception());
      // act
      final result = await repository.cacheReportImage(tBytes);
      // assert
      expect(result, isA<ApiFailure>());
    });
  });

  group('saveReport', () {
    final tReport = DailyReport.empty();

    test(
      'should return ApiSuccess when local data source saves successfully',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.saveReport(any()),
        ).thenAnswer((_) async => {});
        // act
        final result = await repository.saveReport(tReport);
        // assert
        expect(result, ApiSuccess(tReport));
        verify(() => mockLocalDataSource.saveReport(tReport));
      },
    );

    test('should return ApiFailure when local data source throws', () async {
      // arrange
      when(() => mockLocalDataSource.saveReport(any())).thenThrow(Exception());
      // act
      final result = await repository.saveReport(tReport);
      // assert
      expect(result, isA<ApiFailure>());
    });
  });

  group('getReportHistory', () {
    final tHistory = [DailyReport.empty()];

    test(
      'should return ApiSuccess with history when local data source loads successfully',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getReportHistory(),
        ).thenAnswer((_) async => tHistory);
        // act
        final result = await repository.getReportHistory();
        // assert
        expect(result, ApiSuccess(tHistory));
        verify(() => mockLocalDataSource.getReportHistory());
      },
    );

    test('should return ApiFailure when local data source throws', () async {
      // arrange
      when(() => mockLocalDataSource.getReportHistory()).thenThrow(Exception());
      // act
      final result = await repository.getReportHistory();
      // assert
      expect(result, isA<ApiFailure>());
    });
  });

  group('deleteReport', () {
    const tId = '1';

    test(
      'should return ApiSuccess when local data source deletes successfully',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.deleteReport(any()),
        ).thenAnswer((_) async => {});
        // act
        final result = await repository.deleteReport(tId);
        // assert
        expect(result, const ApiSuccess<void>(null));
        verify(() => mockLocalDataSource.deleteReport(tId));
      },
    );

    test('should return ApiFailure when local data source throws', () async {
      // arrange
      when(
        () => mockLocalDataSource.deleteReport(any()),
      ).thenThrow(Exception());
      // act
      final result = await repository.deleteReport(tId);
      // assert
      expect(result, isA<ApiFailure>());
    });
  });
}

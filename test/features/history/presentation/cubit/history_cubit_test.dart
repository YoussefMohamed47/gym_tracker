import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/error/api_result.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/features/daily_report/domain/repository/daily_report_repository.dart';
import 'package:gym_tracker_report/features/history/presentation/cubit/history_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockDailyReportRepository extends Mock implements DailyReportRepository {}

void main() {
  late HistoryCubit cubit;
  late MockDailyReportRepository mockRepository;

  setUp(() {
    mockRepository = MockDailyReportRepository();
    cubit = HistoryCubit(mockRepository);
  });

  group('HistoryCubit', () {
    final tReports = [DailyReport.empty()];

    test('initial state should be HistoryInitial', () {
      expect(cubit.state, HistoryInitial());
    });

    test('should emit [HistoryLoading, HistoryLoaded] when loadHistory is successful', () async {
      // arrange
      when(() => mockRepository.getReportHistory())
          .thenAnswer((_) async => ApiSuccess(tReports));
      
      // act & assert
      final expectedStates = [
        HistoryLoading(),
        HistoryLoaded(tReports),
      ];
      
      expectLater(cubit.stream, emitsInOrder(expectedStates));
      
      await cubit.loadHistory();
    });

    test('should emit [HistoryLoading, HistoryError] when loadHistory fails', () async {
      // arrange
      when(() => mockRepository.getReportHistory())
          .thenAnswer((_) async => const ApiFailure(CacheFailure('Error')));
      
      // act & assert
      final expectedStates = [
        HistoryLoading(),
        const HistoryError('Error'),
      ];
      
      expectLater(cubit.stream, emitsInOrder(expectedStates));
      
      await cubit.loadHistory();
    });
  });
}

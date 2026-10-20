import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/features/daily_report/domain/repository/daily_report_repository.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/cubit/daily_report_cubit.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/cubit/daily_report_state.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/domain/repositories/workout_repository.dart';
import 'package:gym_tracker_report/features/workout/utils/date_utils.dart';

class MockDailyReportRepository implements DailyReportRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWorkoutRepository implements WorkoutRepository {
  final WorkoutSession? sessionToReturn;
  final List<WorkoutSession> historyToReturn;

  MockWorkoutRepository({this.sessionToReturn, this.historyToReturn = const []});

  @override
  Future<WorkoutSession?> getSessionForDate(String dateKey) async {
    return sessionToReturn;
  }

  @override
  Future<List<WorkoutSession>> getHistory() async {
    return historyToReturn;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DailyReportCubit Tests', () {
    late MockDailyReportRepository mockReportRepo;

    setUp(() {
      mockReportRepo = MockDailyReportRepository();
    });

    test('updateField updates training correctly', () {
      final cubit = DailyReportCubit(mockReportRepo);
      cubit.updateField(training: 'Push');

      expect(cubit.state.report.training, equals('Push'));
    });

    test('initTodayTrainingDefault populates default training when session exists', () async {
      final todayKey = WorkoutDateUtils.formatDateKey(DateTime.now());
      final mockSession = WorkoutSession(
        dateKey: todayKey,
        workoutType: WorkoutType.push,
        exerciseLogs: const {},
        displayUnit: WeightUnit.kg,
      );

      final mockWorkoutRepo = MockWorkoutRepository(sessionToReturn: mockSession);

      final cubit = DailyReportCubit(
        mockReportRepo,
        workoutRepository: mockWorkoutRepo,
      );

      // Wait for async initTodayTrainingDefault
      await Future.delayed(Duration.zero);

      expect(cubit.state.report.training, equals('Push'));
    });
  });
}

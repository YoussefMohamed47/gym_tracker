import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/features/daily_report/domain/usecases/get_meal_adherence_usecase.dart';
import 'package:gym_tracker_report/features/daily_report/domain/repository/daily_report_repository.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/core/error/api_result.dart';

class MockDailyReportRepository extends Mock implements DailyReportRepository {}

void main() {
  late MockDailyReportRepository repository;
  late GetMealAdherenceUseCase usecase;

  setUp(() {
    repository = MockDailyReportRepository();
    usecase = GetMealAdherenceUseCase(repository);
  });

  test('should return empty list on failure', () async {
    when(() => repository.getReportHistory()).thenAnswer(
      (_) async => ApiFailure(CacheFailure('error')),
    );

    final result = await usecase();
    expect(result, isEmpty);
  });

  test('should calculate adherence scores correctly', () async {
    final report1 = DailyReport.empty().copyWith(breakfast: 'Eggs', lunch: 'Chicken'); // 2 meals
    final report2 = DailyReport.empty().copyWith(breakfast: 'Oats', dinner: 'Fish'); // 2 meals

    when(() => repository.getReportHistory()).thenAnswer(
      (_) async => ApiSuccess([report1, report2]),
    );

    final result = await usecase();

    expect(result.length, 6);

    // Breakfast: 2/2 = 1.0
    expect(result.firstWhere((p) => p.mealType == 'Breakfast').adherenceScore, 1.0);
    // Lunch: 1/2 = 0.5
    expect(result.firstWhere((p) => p.mealType == 'Lunch').adherenceScore, 0.5);
    // Dinner: 1/2 = 0.5
    expect(result.firstWhere((p) => p.mealType == 'Dinner').adherenceScore, 0.5);
    // Snacks: 0/2 = 0.0
    expect(result.firstWhere((p) => p.mealType == 'Snacks').adherenceScore, 0.0);
  });
}

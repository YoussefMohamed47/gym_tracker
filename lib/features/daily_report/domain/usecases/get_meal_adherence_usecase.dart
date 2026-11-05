import '../../../../core/error/api_result.dart';
import '../models/meal_adherence_data_point.dart';
import '../repository/daily_report_repository.dart';

class GetMealAdherenceUseCase {
  final DailyReportRepository _repository;

  GetMealAdherenceUseCase(this._repository);

  Future<List<MealAdherenceDataPoint>> call() async {
    final result = await _repository.getReportHistory();

    if (result is ApiFailure) {
      return [];
    }

    final history = (result as ApiSuccess).data;
    if (history.isEmpty) {
      return [];
    }

    int totalReports = history.length;
    int breakfastCount = 0;
    int lunchCount = 0;
    int dinnerCount = 0;
    int snackCount = 0;
    int supplementsCount = 0;
    int waterCount = 0;

    for (final report in history) {
      if (report.breakfast.trim().isNotEmpty) breakfastCount++;
      if (report.lunch.trim().isNotEmpty) lunchCount++;
      if (report.dinner.trim().isNotEmpty) dinnerCount++;
      if (report.snack.trim().isNotEmpty) snackCount++;
      if (report.supplements.trim().isNotEmpty) supplementsCount++;
      if (report.water.trim().isNotEmpty) waterCount++;
    }

    return [
      MealAdherenceDataPoint(
        mealType: 'Breakfast',
        adherenceScore: breakfastCount / totalReports,
      ),
      MealAdherenceDataPoint(
        mealType: 'Lunch',
        adherenceScore: lunchCount / totalReports,
      ),
      MealAdherenceDataPoint(
        mealType: 'Dinner',
        adherenceScore: dinnerCount / totalReports,
      ),
      MealAdherenceDataPoint(
        mealType: 'Snacks',
        adherenceScore: snackCount / totalReports,
      ),
      MealAdherenceDataPoint(
        mealType: 'Supplements',
        adherenceScore: supplementsCount / totalReports,
      ),
      MealAdherenceDataPoint(
        mealType: 'Water',
        adherenceScore: waterCount / totalReports,
      ),
    ];
  }
}

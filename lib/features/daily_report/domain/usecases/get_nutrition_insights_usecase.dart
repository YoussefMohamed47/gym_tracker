import '../../../../core/error/api_result.dart';
import '../model/daily_report.dart';
import '../model/meal_entry.dart';
import '../model/meal_slot.dart';
import '../models/nutrition_insights.dart';
import '../repository/daily_report_repository.dart';

class GetNutritionInsightsUseCase {
  final DailyReportRepository _repository;
  final DateTime Function() _now;

  /// How many recent reports the "usual meal" looks at.
  static const usualMealWindow = 30;

  GetNutritionInsightsUseCase(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  Future<NutritionInsights> call() async {
    final result = await _repository.getReportHistory();
    if (result is! ApiSuccess<List<DailyReport>>) {
      return NutritionInsights.empty;
    }
    final reports = result.data.where((r) => r.dateTime != null).toList()
      ..sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

    final today = _dateOnly(_now());
    final loggedDays = reports.map((r) => _dateOnly(r.dateTime!)).toSet();

    // Streak: walk back from today; a missing today doesn't break it yet.
    var cursor = loggedDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (loggedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final lastSeven = [
      for (var i = 6; i >= 0; i--)
        loggedDays.contains(today.subtract(Duration(days: i))),
    ];

    return NutritionInsights(
      streakDays: streak,
      lastSevenDays: lastSeven,
      usualMeals: _usualMeals(reports.take(usualMealWindow).toList()),
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Most frequent set of foods per slot (same names, any order), taken from
  /// the most recent report that had it so quantities are the latest ones.
  static Map<MealSlot, List<MealEntry>> _usualMeals(
    List<DailyReport> newestFirst,
  ) {
    final usual = <MealSlot, List<MealEntry>>{};
    for (final slot in MealSlot.values) {
      final counts = <String, int>{};
      final latest = <String, List<MealEntry>>{};
      for (final report in newestFirst) {
        final entries = slot
            .entriesOf(report)
            .where((e) => e.category != 'Legacy' && e.name.trim().isNotEmpty)
            .toList();
        if (entries.isEmpty) continue;
        final key = (entries.map((e) => e.name.trim()).toList()..sort()).join(
          '|',
        );
        counts[key] = (counts[key] ?? 0) + 1;
        latest.putIfAbsent(key, () => entries);
      }
      if (counts.isEmpty) continue;
      final best = counts.entries.reduce((a, b) => b.value > a.value ? b : a);
      if (best.value >= 2) usual[slot] = latest[best.key]!;
    }
    return usual;
  }
}

import 'daily_report.dart';
import 'meal_entry.dart';

/// The six meals of a [DailyReport], in the order the form has always used.
///
/// One place maps a slot to its report fields, so the timeline, the "usual
/// meal" shortcut and the insights all read and write the same data.
enum MealSlot {
  breakfast('الإفطار', 'Breakfast'),
  lunch('الغداء', 'Lunch'),
  dinner('العشاء', 'Dinner'),
  snack('السناك', 'Snack'),
  beforeTraining('قبل التمرين', 'Pre-workout'),
  afterTraining('بعد التمرين', 'Post-workout');

  final String arabicName;
  final String englishName;
  const MealSlot(this.arabicName, this.englishName);

  String textOf(DailyReport r) => switch (this) {
    breakfast => r.breakfast,
    lunch => r.lunch,
    dinner => r.dinner,
    snack => r.snack,
    beforeTraining => r.beforeTraining,
    afterTraining => r.afterTraining,
  };

  List<MealEntry> entriesOf(DailyReport r) => switch (this) {
    breakfast => r.breakfastEntries,
    lunch => r.lunchEntries,
    dinner => r.dinnerEntries,
    snack => r.snackEntries,
    beforeTraining => r.beforeTrainingEntries,
    afterTraining => r.afterTrainingEntries,
  };

  bool isLogged(DailyReport r) =>
      textOf(r).trim().isNotEmpty || entriesOf(r).isNotEmpty;

  /// [r] with this meal replaced by [entries]; the legacy text is kept in sync.
  DailyReport withEntries(DailyReport r, List<MealEntry> entries) {
    final text = mealEntriesToLegacyText(entries);
    return switch (this) {
      breakfast => r.copyWith(breakfast: text, breakfastEntries: entries),
      lunch => r.copyWith(lunch: text, lunchEntries: entries),
      dinner => r.copyWith(dinner: text, dinnerEntries: entries),
      snack => r.copyWith(snack: text, snackEntries: entries),
      beforeTraining => r.copyWith(
        beforeTraining: text,
        beforeTrainingEntries: entries,
      ),
      afterTraining => r.copyWith(
        afterTraining: text,
        afterTrainingEntries: entries,
      ),
    };
  }
}

import 'package:equatable/equatable.dart';

import '../model/meal_entry.dart';
import '../model/meal_slot.dart';

/// Habit numbers for the Today card, derived from shared report history.
class NutritionInsights extends Equatable {
  /// Consecutive days with a shared report, ending today (or yesterday when
  /// today's report has not been shared yet, so the streak is still alive).
  final int streakDays;

  /// Whether each of the last seven days has a shared report, oldest first;
  /// the last value is today.
  final List<bool> lastSevenDays;

  /// The meal you have logged most often for each slot, when you have repeated
  /// it at least twice recently.
  final Map<MealSlot, List<MealEntry>> usualMeals;

  const NutritionInsights({
    required this.streakDays,
    required this.lastSevenDays,
    required this.usualMeals,
  });

  static const empty = NutritionInsights(
    streakDays: 0,
    lastSevenDays: [false, false, false, false, false, false, false],
    usualMeals: {},
  );

  @override
  List<Object?> get props => [streakDays, lastSevenDays, usualMeals];
}

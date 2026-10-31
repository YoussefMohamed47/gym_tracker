import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/meal_entry.dart';

void main() {
  group('Structured Nutrition & MealEntry Tests', () {
    test('MealEntry formats quantity and text correctly', () {
      const entry1 = MealEntry(
        name: 'صدر دجاج مشوي',
        category: 'بروتين',
        quantity: 180,
        unit: 'جم',
      );
      expect(entry1.displayQuantity, '180 جم');
      expect(entry1.displayText, 'صدر دجاج مشوي (180 جم)');

      const entry2 = MealEntry(
        name: 'طبق سلطة',
        category: 'خضروات',
        note: 'بدون زيت',
      );
      expect(entry2.displayText, 'طبق سلطة بدون زيت');
    });

    test('FoodOptionParser parses catalog option strings correctly', () {
      final parsed = FoodOptionParser.fromCatalog(
        'صدر دجاج مشوي (180جم)',
        'بروتين',
      );

      expect(parsed.name, 'صدر دجاج مشوي');
      expect(parsed.quantity, 180.0);
      expect(parsed.unit, 'جم');
    });

    test('DailyReport backward compatibility with structured entries', () {
      const entry = MealEntry(
        name: 'بيض مسلوق',
        category: 'بروتين',
        quantity: 100,
        unit: 'جم',
      );

      final report = DailyReport.empty().copyWith(
        breakfastEntries: [entry],
      );

      expect(report.breakfast, 'بيض مسلوق (100 جم)');
      expect(report.breakfastEntries, [entry]);
      expect(report.mealsCompletionRatio, 0.25);
    });
  });
}

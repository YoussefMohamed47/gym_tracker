import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/daily_report/data/datasources/nutrition_catalog.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/meal_entry.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/utils/meal_parser.dart';

void main() {
  group('Structured Nutrition & MealEntry Tests', () {
    test('MealEntry formats quantity and text correctly', () {
      const entry1 = MealEntry(
        id: '1',
        foodName: 'صدر دجاج مشوي',
        quantity: 180,
        unit: 'جم',
      );
      expect(entry1.formattedQuantity, '180 جم');
      expect(entry1.formattedText, 'صدر دجاج مشوي (180 جم)');

      const entry2 = MealEntry(
        id: '2',
        foodName: 'طبق سلطة',
        notes: 'بدون زيت',
      );
      expect(entry2.formattedText, 'طبق سلطة - بدون زيت');
    });

    test('NutritionCatalog parses catalog option strings correctly', () {
      final parsed = NutritionCatalog.parseCatalogOption(
        'صدر دجاج مشوي (180جم)',
        'بروتين',
      );

      expect(parsed.name, 'صدر دجاج مشوي');
      expect(parsed.suggestedQuantity, 180.0);
      expect(parsed.unit, 'جم');
    });

    test('MealParser parses string into structured MealEntry objects', () {
      const text = 'صدر دجاج مشوي (180جم) + أرز أبيض مطهي (250جم)';
      final entries = MealParser.parseToMealEntries(text);

      expect(entries.length, 2);
      expect(entries[0].foodName, 'صدر دجاج مشوي');
      expect(entries[0].quantity, 180.0);
      expect(entries[1].foodName, 'أرز أبيض مطهي');
      expect(entries[1].quantity, 250.0);
    });

    test('DailyReport backward compatibility with structured entries', () {
      const entry = MealEntry(
        id: 'm1',
        foodName: 'بيض مسلوق',
        quantity: 100,
        unit: 'جم',
      );

      final report = DailyReport.empty().copyWith(
        breakfastEntries: [entry],
      );

      expect(report.breakfast, 'بيض مسلوق (100 جم)');
      expect(report.getBreakfastEntries(), [entry]);
      expect(report.mealsCompletionRatio, 0.25);
    });
  });
}

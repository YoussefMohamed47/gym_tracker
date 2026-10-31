import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/meal_entry.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';

void main() {
  group('Structured meal entries', () {
    test('parse unambiguous catalog quantities separately', () {
      final entry = FoodOptionParser.fromCatalog('صدر دجاج مشوي (180جم)', 'بروتين');
      expect(entry.name, 'صدر دجاج مشوي');
      expect(entry.quantity, 180);
      expect(entry.unit, 'جم');
      expect(entry.displayText, 'صدر دجاج مشوي (180 جم)');
    });

    test('preserve dietary instructions and do not treat them as quantities', () {
      final entry = FoodOptionParser.fromCatalog('فول (150جم) + نصف كمية النشويات فقط', 'بروتين');
      expect(entry.name, 'فول');
      expect(entry.quantity, 150);
      expect(entry.note, '+ نصف كمية النشويات فقط');
    });

    test('avoid guessing the weight of alternative foods', () {
      final entry = FoodOptionParser.fromCatalog('شيدر لايت (40جم) أو شيدر عادي (20جم)', 'أجبان');
      expect(entry.quantity, isNull);
      expect(entry.name, 'شيدر لايت (40جم) أو شيدر عادي (20جم)');
    });

    test('new entry quantity is mutable without changing food name', () {
      const entry = MealEntry(name: 'أرز أبيض مطهي', category: 'نشويات', quantity: 250, unit: 'جم');
      final adjusted = entry.copyWith(quantity: 180);
      expect(adjusted.name, entry.name);
      expect(adjusted.displayQuantity, '180 جم');
    });

    test('individual serialized entries retain quantity and notes', () {
      const entries = [MealEntry(name: 'فول', category: 'بروتين', quantity: 150, unit: 'جم', note: '+ نصف كمية النشويات فقط')];
      expect(decodeMealEntries(encodeMealEntries(entries)), entries);
    });

    test('old reports without structured fields remain readable', () {
      final report = DailyReport.empty().copyWith(breakfast: 'خبز بلدي (80جم)');
      final restored = DailyReport.fromJson(report.toJson()..remove('breakfastEntries'));
      expect(restored.breakfast, 'خبز بلدي (80جم)');
      expect(restored.breakfastEntries, isEmpty);
      expect(restored.mealsCompletionRatio, greaterThan(0));
    });
  });
}

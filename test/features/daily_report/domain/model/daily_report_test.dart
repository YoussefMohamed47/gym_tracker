import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';

void main() {
  group('DailyReport', () {
    final tReport = DailyReport(
      id: '123',
      breakfast: 'Eggs',
      lunch: 'Chicken',
      snack: 'Nuts',
      beforeTraining: 'Coffee',
      afterTraining: 'Shake',
      dinner: 'Steak',
      water: '2L',
      training: 'Push',
      cardio: '30m',
      supplements: 'Creatine',
      sleepTime: '8h',
      notes: 'Good day',
      dateTime: DateTime(2026, 7, 2),
      imagePath: 'path/to/image.png',
    );

    test('should return correct JSON map from toJson', () {
      final result = tReport.toJson();
      expect(result['id'], '123');
      expect(result['breakfast'], 'Eggs');
      expect(result['dateTime'], '2026-07-02T00:00:00.000');
    });

    test('should return correct DailyReport from fromJson', () {
      final json = tReport.toJson();
      final result = DailyReport.fromJson(json);
      expect(result, tReport);
    });

    test('isEmpty should return true only when all fields are empty', () {
      expect(DailyReport.empty().isEmpty, true);

      final reportWithData = DailyReport.empty().copyWith(breakfast: 'Eggs');
      expect(reportWithData.isEmpty, false);
    });
  });
}

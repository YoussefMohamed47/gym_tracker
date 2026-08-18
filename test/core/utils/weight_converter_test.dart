import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';

void main() {
  group('WeightConverter', () {
    test('kgToLb converts correctly', () {
      // 100 kg * 2.20462262185 = 220.462262185 lb
      expect(WeightConverter.kgToLb(100), closeTo(220.462, 0.001));
    });

    test('lbToKg converts correctly', () {
      // 220.462262185 lb / 2.20462262185 = 100 kg
      expect(WeightConverter.lbToKg(220.462262185), closeTo(100, 0.0001));
    });

    test('convert method handles same unit', () {
      expect(WeightConverter.convert(100, WeightUnit.kg, WeightUnit.kg), 100);
      expect(WeightConverter.convert(220, WeightUnit.lb, WeightUnit.lb), 220);
    });

    test('convert method handles different units', () {
      expect(WeightConverter.convert(100, WeightUnit.kg, WeightUnit.lb), closeTo(220.462, 0.001));
      expect(WeightConverter.convert(220.462262185, WeightUnit.lb, WeightUnit.kg), closeTo(100, 0.0001));
    });

    test('round-trip precision is preserved (KG -> LB -> KG)', () {
      const double initialKg = 87.5;
      final double lbValue = WeightConverter.kgToLb(initialKg);
      final double resultKg = WeightConverter.lbToKg(lbValue);
      
      // Precision should be virtually identical
      expect(resultKg, equals(initialKg));
    });

    test('format rounds correctly', () {
      expect(WeightConverter.format(100.456, decimals: 1), '100.5');
      expect(WeightConverter.format(100.456, decimals: 2), '100.46');
    });
  });
}

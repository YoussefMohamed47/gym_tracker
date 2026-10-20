import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/numeric_keypad_sheet.dart';

void main() {
  group('NumericKeypadSheet Tests', () {
    test('formatCleanNumber rounds floating point artifacts cleanly', () {
      // Test cases addressing 32.69999999999 -> 32.7 issue
      expect(NumericKeypadSheet.formatCleanNumber(32.699999999999996), equals('32.7'));
      expect(NumericKeypadSheet.formatCleanNumber(30.2 + 2.5), equals('32.7'));
      expect(NumericKeypadSheet.formatCleanNumber(30.0), equals('30'));
      expect(NumericKeypadSheet.formatCleanNumber(32.50), equals('32.5'));
      expect(NumericKeypadSheet.formatCleanNumber(32.75), equals('32.75'));
    });
  });
}

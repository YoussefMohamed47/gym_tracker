import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/utils/plural.dart';

void main() {
  test('uses the singular for one', () {
    expect(countOf(1, 'set'), '1 set');
  });

  test('adds s for other counts', () {
    expect(countOf(0, 'set'), '0 sets');
    expect(countOf(3, 'set'), '3 sets');
  });

  test('uses a given plural form', () {
    expect(countOf(2, 'glass', 'glasses'), '2 glasses');
  });
}

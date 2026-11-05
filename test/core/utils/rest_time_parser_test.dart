import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/utils/rest_time_parser.dart';

void main() {
  group('RestTimeParser', () {
    test('parses minute ranges correctly', () {
      expect(RestTimeParser.parseInSeconds('2-3m'), equals(120));
      expect(RestTimeParser.parseInSeconds('1-2m'), equals(60));
      expect(RestTimeParser.parseInSeconds('2-3 min'), equals(120));
    });

    test('parses single minute strings correctly', () {
      expect(RestTimeParser.parseInSeconds('1m'), equals(60));
      expect(RestTimeParser.parseInSeconds('2m'), equals(120));
      expect(RestTimeParser.parseInSeconds('3 min'), equals(180));
    });

    test('parses second strings correctly', () {
      expect(RestTimeParser.parseInSeconds('90s'), equals(90));
      expect(RestTimeParser.parseInSeconds('45s'), equals(45));
    });

    test('handles fallback for null or empty strings', () {
      expect(RestTimeParser.parseInSeconds(null), equals(90));
      expect(RestTimeParser.parseInSeconds(''), equals(90));
    });

    test('formats display strings correctly', () {
      expect(RestTimeParser.formatDisplay(120), equals('2 Minutes'));
      expect(RestTimeParser.formatDisplay(60), equals('1 Minute'));
      expect(RestTimeParser.formatDisplay(90), equals('1:30 Min'));
      expect(RestTimeParser.formatDisplay(45), equals('45 Seconds'));
    });
  });
}

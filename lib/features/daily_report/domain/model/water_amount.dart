/// Reads and writes the free-text water field of a [DailyReport].
///
/// The field stays a plain string so older reports and exports keep working;
/// this only gives the UI a number to show progress against and to add to.
class WaterAmount {
  WaterAmount._();

  static const _arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const _persianDigits = '۰۱۲۳۴۵۶۷۸۹';

  static String _normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final ch in input.split('')) {
      final a = _arabicDigits.indexOf(ch);
      final p = _persianDigits.indexOf(ch);
      if (a >= 0) {
        buffer.write(a);
      } else if (p >= 0) {
        buffer.write(p);
      } else if (ch == '٫' || ch == ',') {
        buffer.write('.');
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// Liters in [text], or null when there is no number in it.
  ///
  /// "3", "2.5 لتر", "2.5L" are liters; "750 مل", "1500ml" or any bare number
  /// above 20 are milliliters; "8 أكواب" / "8 cups" are 250 ml glasses.
  static double? parseLiters(String text) {
    final normalized = _normalizeDigits(text.trim()).toLowerCase();
    if (normalized.isEmpty) return null;
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(normalized);
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!);
    if (value == null) return null;

    final isMl = normalized.contains('ml') || normalized.contains('مل');
    final isGlasses =
        normalized.contains('كوب') ||
        normalized.contains('أكواب') ||
        normalized.contains('اكواب') ||
        normalized.contains('cup') ||
        normalized.contains('glass');
    if (isMl) return value / 1000;
    if (isGlasses) return value * 0.25;
    if (value > 20) return value / 1000; // a bare "1500" means ml
    return value;
  }

  /// The text written back to the report, e.g. "2.5 لتر".
  static String format(double liters) {
    final rounded = (liters * 100).round() / 100;
    final text = rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toString();
    return '$text لتر';
  }
}

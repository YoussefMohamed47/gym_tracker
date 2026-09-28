import 'package:intl/intl.dart';

class ReportFormatter {
  /// Converts Western digits (0-9) to Arabic-Indic digits (٠-٩)
  static String toArabicDigits(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], eastern[i]);
    }
    return result;
  }

  /// Formats date for Arabic reports (e.g. "الثلاثاء، ١٤ مايو ٢٠٢٤")
  static String formatArabicDate(DateTime? dateTime, {bool useArabicDigits = true}) {
    final date = dateTime ?? DateTime.now();
    
    final dayName = _arabicDayNames[date.weekday] ?? '';
    final monthName = _arabicMonthNames[date.month] ?? '';
    final dayStr = date.day.toString();
    final yearStr = date.year.toString();

    final formatted = '$dayName، $dayStr $monthName $yearStr';
    return useArabicDigits ? toArabicDigits(formatted) : formatted;
  }

  /// Formats date for Latin reports (e.g. "TUE, MAY 14, 2024")
  static String formatEnglishDate(DateTime? dateTime) {
    final date = dateTime ?? DateTime.now();
    return DateFormat('EEE, MMM d, yyyy').format(date).toUpperCase();
  }

  /// Localizes duration strings for Arabic (e.g. "45 min" -> "٤٥ دقيقة", "7 hours" -> "٧ ساعات")
  static String localizeArabicDuration(String rawDuration) {
    if (rawDuration.trim().isEmpty) return '';

    String text = rawDuration.trim();
    
    // Check for hours
    final hoursMatch = RegExp(r'(\d+)\s*(hrs?|hours?|ساعات?|ساعة)').firstMatch(text);
    if (hoursMatch != null) {
      final hrs = hoursMatch.group(1)!;
      return '${toArabicDigits(hrs)} ساعات';
    }

    // Check for mins
    final minsMatch = RegExp(r'(\d+)\s*(mins?|minutes?|دقائق?|دقيقة)').firstMatch(text);
    if (minsMatch != null) {
      final mins = minsMatch.group(1)!;
      return '${toArabicDigits(mins)} دقيقة';
    }

    // Single number
    final numberMatch = RegExp(r'^(\d+)$').firstMatch(text);
    if (numberMatch != null) {
      return '${toArabicDigits(numberMatch.group(1)!)} دقيقة';
    }

    return toArabicDigits(text);
  }

  /// Localizes workout type names for Arabic
  static String localizeArabicWorkoutType(String typeName) {
    final lower = typeName.toLowerCase().trim();
    if (lower.contains('push')) return 'تمرين دفع (Push)';
    if (lower.contains('pull')) return 'تمرين سحب (Pull)';
    if (lower.contains('leg')) return 'تمرين أرجل (Legs)';
    if (lower.contains('upper')) return 'جزء علوي (Upper)';
    if (lower.contains('lower')) return 'جزء سفلي (Lower)';
    if (lower.contains('rest') || lower == 'راحة') return 'يوم راحة';
    return toArabicDigits(typeName);
  }

  static const Map<int, String> _arabicDayNames = {
    DateTime.monday: 'الإثنين',
    DateTime.tuesday: 'الثلاثاء',
    DateTime.wednesday: 'الأربعاء',
    DateTime.thursday: 'الخميس',
    DateTime.friday: 'الجمعة',
    DateTime.saturday: 'السبت',
    DateTime.sunday: 'الأحد',
  };

  static const Map<int, String> _arabicMonthNames = {
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'أبريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };
}

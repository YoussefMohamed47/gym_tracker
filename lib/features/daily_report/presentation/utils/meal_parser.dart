import '../../../../core/utils/report_formatter.dart';

class ParsedFoodItem {
  final String name;
  final String? quantity;

  const ParsedFoodItem({
    required this.name,
    this.quantity,
  });
}

class MealParser {
  /// Parses meal string into a list of food items with clean names & quantity chips
  static List<ParsedFoodItem> parse(String mealText, {bool useArabicDigits = true}) {
    if (mealText.trim().isEmpty) return [];

    // Split by delimiters
    final rawParts = mealText.split(RegExp(r'[\+\,\;\n]'));
    final List<ParsedFoodItem> items = [];

    for (final rawPart in rawParts) {
      final part = rawPart.trim();
      if (part.isEmpty) continue;

      // Pattern 1: Text (100جم) or Text (100g) or Text (150مل)
      final parenRegex = RegExp(r'^(.*?)\s*[\(\[\{](.*?)[\)\]\}]\s*$');
      final parenMatch = parenRegex.firstMatch(part);

      if (parenMatch != null) {
        final name = parenMatch.group(1)!.trim();
        var quantity = parenMatch.group(2)!.trim();
        if (useArabicDigits) {
          quantity = ReportFormatter.toArabicDigits(quantity);
        }
        if (name.isNotEmpty) {
          items.add(ParsedFoodItem(
            name: name,
            quantity: quantity.isNotEmpty ? quantity : null,
          ));
          continue;
        }
      }

      // Pattern 2: Text - 100g or Text : 100g
      final dashRegex = RegExp(r'^(.*?)\s*[\-\:]\s*(\d+.*)$');
      final dashMatch = dashRegex.firstMatch(part);

      if (dashMatch != null) {
        final name = dashMatch.group(1)!.trim();
        var quantity = dashMatch.group(2)!.trim();
        if (useArabicDigits) {
          quantity = ReportFormatter.toArabicDigits(quantity);
        }
        if (name.isNotEmpty) {
          items.add(ParsedFoodItem(
            name: name,
            quantity: quantity.isNotEmpty ? quantity : null,
          ));
          continue;
        }
      }

      // Plain text without quantity pattern
      items.add(ParsedFoodItem(
        name: useArabicDigits ? ReportFormatter.toArabicDigits(part) : part,
        quantity: null,
      ));
    }

    return items;
  }

  /// Checks if calories/macros are mentioned in the report string and extracts values
  static MacroBreakdown? extractMacros(String fullText) {
    // Looks for numbers associated with cal/kcal, protein, carbs, fat
    final calMatch = RegExp(r'(\d+)\s*(كالوري|سعرة|kcal|cal)', caseSensitive: false).firstMatch(fullText);
    final pMatch = RegExp(r'(\d+)\s*(جم\s*بروتين|g\s*protein|بروتين)', caseSensitive: false).firstMatch(fullText);
    final cMatch = RegExp(r'(\d+)\s*(جم\s*نشويات|g\s*carbs|نشويات)', caseSensitive: false).firstMatch(fullText);
    final fMatch = RegExp(r'(\d+)\s*(جم\s*دهون|g\s*fat|دهون)', caseSensitive: false).firstMatch(fullText);

    if (calMatch == null && pMatch == null && cMatch == null && fMatch == null) {
      return null;
    }

    return MacroBreakdown(
      calories: int.tryParse(calMatch?.group(1) ?? '0') ?? 0,
      proteinGrams: int.tryParse(pMatch?.group(1) ?? '0') ?? 0,
      carbsGrams: int.tryParse(cMatch?.group(1) ?? '0') ?? 0,
      fatGrams: int.tryParse(fMatch?.group(1) ?? '0') ?? 0,
    );
  }
}

class MacroBreakdown {
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  const MacroBreakdown({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  bool get hasData => calories > 0 || proteinGrams > 0 || carbsGrams > 0 || fatGrams > 0;
}

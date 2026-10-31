import 'dart:convert';
import 'package:equatable/equatable.dart';

/// A logged food with an independently editable quantity. Legacy strings remain
/// available on DailyReport for older saved reports and existing exports.
class MealEntry extends Equatable {
  final String name;
  final String category;
  final double? quantity;
  final String? unit;
  final String? note;
  final String? catalogOption;

  const MealEntry({
    required this.name,
    required this.category,
    this.quantity,
    this.unit,
    this.note,
    this.catalogOption,
  });

  MealEntry copyWith({double? quantity, String? unit, String? note}) => MealEntry(
    name: name,
    category: category,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    note: note ?? this.note,
    catalogOption: catalogOption,
  );

  Map<String, dynamic> toJson() => {
    'name': name, 'category': category, 'quantity': quantity,
    'unit': unit, 'note': note, 'catalogOption': catalogOption,
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    name: (json['name'] as String?) ?? '',
    category: (json['category'] as String?) ?? '',
    quantity: (json['quantity'] as num?)?.toDouble(),
    unit: json['unit'] as String?,
    note: json['note'] as String?,
    catalogOption: json['catalogOption'] as String?,
  );

  String get displayQuantity {
    if (quantity == null) return '';
    final amount = quantity! == quantity!.roundToDouble()
        ? quantity!.toInt().toString() : quantity.toString();
    return '$amount ${unit ?? ''}'.trim();
  }

  String get displayText => [
    name,
    if (quantity != null) '($displayQuantity)',
    if (note != null && note!.trim().isNotEmpty) note!.trim(),
  ].join(' ');

  @override
  List<Object?> get props => [name, category, quantity, unit, note, catalogOption];
}

/// Conversion happens only when an old option has ONE unambiguous numeric unit.
/// Composite alternatives are retained as text; we never guess quantities.
class FoodOptionParser {
  static final RegExp _quantityPattern = RegExp(r'\((\d+(?:[.,]\d+)?)\s*(جم|جرام|مل|ml|g|قطعة)\)');

  static MealEntry fromCatalog(String option, String category) {
    final matches = _quantityPattern.allMatches(option).toList();
    if (matches.length != 1) {
      return MealEntry(name: option, category: category, catalogOption: option);
    }
    final match = matches.single;
    final prefix = option.substring(0, match.start).trim();
    final suffix = option.substring(match.end).trim();
    final normalized = match.group(1)!.replaceAll(',', '.');
    return MealEntry(
      name: prefix.isEmpty ? option : prefix,
      category: category,
      quantity: double.tryParse(normalized),
      unit: match.group(2),
      note: suffix.isEmpty ? null : suffix,
      catalogOption: option,
    );
  }
}

String mealEntriesToLegacyText(List<MealEntry> entries) =>
    entries.map((e) => e.displayText).where((e) => e.isNotEmpty).join(' + ');

/// Hive stores each entry independently as JSON, leaving the 15 original
/// fields unchanged and allowing old records to decode without any migration.
List<String> encodeMealEntries(List<MealEntry>? entries) =>
    (entries ?? const <MealEntry>[]).map((entry) => jsonEncode(entry.toJson())).toList();

List<MealEntry> decodeMealEntries(List<String>? encoded) {
  if (encoded == null) return const <MealEntry>[];
  final result = <MealEntry>[];
  for (final value in encoded) {
    try {
      final parsed = jsonDecode(value);
      if (parsed is Map<String, dynamic>) {
        final entry = MealEntry.fromJson(parsed);
        if (entry.name.trim().isNotEmpty) result.add(entry);
      }
    } catch (_) {
      // Retain the unparseable entry as text rather than discarding food.
      result.add(MealEntry(name: value, category: 'Legacy'));
    }
  }
  return result;
}

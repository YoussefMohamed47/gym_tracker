import 'package:equatable/equatable.dart';

class FoodOption extends Equatable {
  final String id;
  final String name;
  final String categoryName;
  final double? suggestedQuantity;
  final String? unit; // e.g. 'جم', 'مل', etc.
  final String? notes; // optional instructions like '+ نصف كمية النشويات فقط'
  final String rawString;

  const FoodOption({
    required this.id,
    required this.name,
    required this.categoryName,
    this.suggestedQuantity,
    this.unit,
    this.notes,
    required this.rawString,
  });

  String get formattedSuggestedQuantity {
    if (suggestedQuantity == null) return '';
    final qStr = (suggestedQuantity! % 1 == 0)
        ? suggestedQuantity!.toInt().toString()
        : suggestedQuantity!.toString();
    if (unit != null && unit!.isNotEmpty) {
      return '$qStr $unit';
    }
    return qStr;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    categoryName,
    suggestedQuantity,
    unit,
    notes,
    rawString,
  ];
}

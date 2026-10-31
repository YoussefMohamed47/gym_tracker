import 'package:equatable/equatable.dart';

class MealAdherenceDataPoint extends Equatable {
  final String mealType;
  final double adherenceScore; // 0.0 to 1.0

  const MealAdherenceDataPoint({
    required this.mealType,
    required this.adherenceScore,
  });

  @override
  List<Object?> get props => [mealType, adherenceScore];
}

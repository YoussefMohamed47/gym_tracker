import 'package:equatable/equatable.dart';

class ExerciseSetLog extends Equatable {
  final double? weightKg;
  final bool isPerformed;

  const ExerciseSetLog({this.weightKg, this.isPerformed = false});

  ExerciseSetLog copyWith({double? weightKg, bool? isPerformed}) {
    return ExerciseSetLog(
      weightKg: weightKg ?? this.weightKg,
      isPerformed: isPerformed ?? this.isPerformed,
    );
  }

  @override
  List<Object?> get props => [weightKg, isPerformed];
}

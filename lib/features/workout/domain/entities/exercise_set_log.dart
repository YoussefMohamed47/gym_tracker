import 'package:equatable/equatable.dart';

class ExerciseSetLog extends Equatable {
  final double? weightKg;
  final int? actualReps;
  final bool isPerformed;

  const ExerciseSetLog({
    this.weightKg,
    this.actualReps,
    this.isPerformed = false,
  });

  ExerciseSetLog copyWith({
    double? weightKg,
    int? actualReps,
    bool? isPerformed,
  }) {
    return ExerciseSetLog(
      weightKg: weightKg ?? this.weightKg,
      actualReps: actualReps ?? this.actualReps,
      isPerformed: isPerformed ?? this.isPerformed,
    );
  }

  @override
  List<Object?> get props => [weightKg, actualReps, isPerformed];
}

import 'package:equatable/equatable.dart';
import '../../../../core/utils/weight_converter.dart';
import 'exercise_set_log.dart';

class ExerciseLog extends Equatable {
  final String plannedExerciseId;
  final String performedExerciseId;

  /// V2: Per-set data
  final List<ExerciseSetLog> sets;

  /// Legacy V1: Single weight per exercise
  final double? weightKg;

  /// Legacy V1: Performance status per exercise
  final bool isPerformed;

  final String? imagePath;
  final DateTime timestamp;
  final WeightUnit displayUnit;

  const ExerciseLog({
    required this.plannedExerciseId,
    required this.performedExerciseId,
    this.sets = const [],
    this.weightKg,
    this.isPerformed = false,
    this.imagePath,
    required this.timestamp,
    this.displayUnit = WeightUnit.kg,
  });

  /// Set [index] has numbers but isn't ticked while a later set is: it was
  /// most likely done and the tick forgotten, so it would go uncounted.
  /// (New sets are prefilled from last time, so numbers alone mean nothing.)
  bool setLooksForgotten(int index) {
    if (index < 0 || index >= sets.length) return false;
    final set = sets[index];
    final hasNumbers = (set.weightKg ?? 0) > 0 || (set.actualReps ?? 0) > 0;
    return !set.isPerformed &&
        hasNumbers &&
        sets.skip(index + 1).any((s) => s.isPerformed);
  }

  ExerciseLog copyWith({
    String? plannedExerciseId,
    String? performedExerciseId,
    List<ExerciseSetLog>? sets,
    double? weightKg,
    bool? isPerformed,
    String? imagePath,
    DateTime? timestamp,
    WeightUnit? displayUnit,
  }) {
    return ExerciseLog(
      plannedExerciseId: plannedExerciseId ?? this.plannedExerciseId,
      performedExerciseId: performedExerciseId ?? this.performedExerciseId,
      sets: sets ?? this.sets,
      weightKg: weightKg ?? this.weightKg,
      isPerformed: isPerformed ?? this.isPerformed,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      displayUnit: displayUnit ?? this.displayUnit,
    );
  }

  @override
  List<Object?> get props => [
    plannedExerciseId,
    performedExerciseId,
    sets,
    weightKg,
    isPerformed,
    imagePath,
    timestamp,
    displayUnit,
  ];
}

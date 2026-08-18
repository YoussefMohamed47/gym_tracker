class ExerciseLog {
  final String plannedExerciseId;
  final String performedExerciseId;
  final double? weightKg;
  final bool isPerformed;
  final String? imagePath;
  final DateTime timestamp;

  const ExerciseLog({
    required this.plannedExerciseId,
    required this.performedExerciseId,
    this.weightKg,
    this.isPerformed = false,
    this.imagePath,
    required this.timestamp,
  });

  ExerciseLog copyWith({
    String? performedExerciseId,
    double? weightKg,
    bool? isPerformed,
    String? imagePath,
    DateTime? timestamp,
  }) {
    return ExerciseLog(
      plannedExerciseId: plannedExerciseId,
      performedExerciseId: performedExerciseId ?? this.performedExerciseId,
      weightKg: weightKg ?? this.weightKg,
      isPerformed: isPerformed ?? this.isPerformed,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

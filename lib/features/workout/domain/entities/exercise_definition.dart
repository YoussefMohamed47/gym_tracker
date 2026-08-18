class ExerciseDefinition {
  final String id;
  final String name;
  final String? videoUrl;
  final bool isWeightAllowed;
  final List<String> alternatives;

  const ExerciseDefinition({
    required this.id,
    required this.name,
    this.videoUrl,
    this.isWeightAllowed = true,
    this.alternatives = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseDefinition &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

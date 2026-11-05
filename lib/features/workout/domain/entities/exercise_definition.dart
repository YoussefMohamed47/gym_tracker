class ExerciseDefinition {
  final String id;
  final String name;
  final String? videoUrl;
  final List<String>? pairedVideoUrls;
  final String? tempoNote;
  final bool isWeightAllowed;
  final List<String> alternatives;

  /// Short coaching steps, shown under "How to" (empty when not written yet).
  final List<String> howTo;

  /// Suggested reps for this exercise when used as a swap, e.g. "8-12".
  final String? repRange;

  const ExerciseDefinition({
    required this.id,
    required this.name,
    this.videoUrl,
    this.pairedVideoUrls,
    this.tempoNote,
    this.isWeightAllowed = true,
    this.alternatives = const [],
    this.howTo = const [],
    this.repRange,
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

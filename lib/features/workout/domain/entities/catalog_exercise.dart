class CatalogExercise {
  final String id;
  final String name;
  final int sets;
  final String repsRange; // e.g. "6-10", "10-20s" for timed holds
  final String restRange; // e.g. "2-3m"
  final String? tempoNote; // e.g. "Light weight, slow tempo"
  final String videoUrl;
  final List<String>? pairedVideoUrls; // for supersets, second exercise's video
  final List<String> alternatives;

  const CatalogExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.repsRange,
    required this.restRange,
    this.tempoNote,
    required this.videoUrl,
    this.pairedVideoUrls,
    this.alternatives = const [],
  });

  bool get isSuperset => pairedVideoUrls != null && pairedVideoUrls!.isNotEmpty;

  CatalogExercise copyWith({
    String? id,
    String? name,
    int? sets,
    String? repsRange,
    String? restRange,
    String? tempoNote,
    String? videoUrl,
    List<String>? pairedVideoUrls,
    List<String>? alternatives,
  }) {
    return CatalogExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      repsRange: repsRange ?? this.repsRange,
      restRange: restRange ?? this.restRange,
      tempoNote: tempoNote ?? this.tempoNote,
      videoUrl: videoUrl ?? this.videoUrl,
      pairedVideoUrls: pairedVideoUrls ?? this.pairedVideoUrls,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogExercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sets == other.sets &&
          repsRange == other.repsRange &&
          restRange == other.restRange &&
          tempoNote == other.tempoNote &&
          videoUrl == other.videoUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      sets.hashCode ^
      repsRange.hashCode ^
      restRange.hashCode ^
      tempoNote.hashCode ^
      videoUrl.hashCode;
}

import 'package:hive_ce/hive.dart';

/// Alternatives you added yourself from the Swap sheet's search, per planned
/// exercise. Kept in the preferences box so they stay across app updates.
class CustomAlternativesStore {
  static const _key = 'custom_alternatives_v1';
  final Box _box;

  CustomAlternativesStore(this._box);

  Map<String, List<String>> _all() {
    final raw = _box.get(_key);
    if (raw is! Map) return {};
    return {
      for (final e in raw.entries)
        if (e.key is String && e.value is List)
          e.key as String: List<String>.from(
            (e.value as List).whereType<String>(),
          ),
    };
  }

  List<String> forExercise(String plannedId) => _all()[plannedId] ?? const [];

  Future<void> add(String plannedId, String exerciseId) async {
    final all = _all();
    final list = all[plannedId] ?? <String>[];
    if (exerciseId == plannedId || list.contains(exerciseId)) return;
    all[plannedId] = [...list, exerciseId];
    // put() updates memory synchronously; the returned future is the disk write.
    await _box.put(_key, all);
  }

  Future<void> remove(String plannedId, String exerciseId) async {
    final all = _all();
    final list = all[plannedId];
    if (list == null) return;
    list.remove(exerciseId);
    if (list.isEmpty) {
      all.remove(plannedId);
    } else {
      all[plannedId] = list;
    }
    await _box.put(_key, all);
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/weight_converter.dart';
import '../models/workout_session_model.dart';

abstract class WorkoutLocalDataSource {
  Future<WorkoutSessionModel?> getSessionForDate(String dateKey);
  Future<void> saveSession(WorkoutSessionModel session);
  Future<void> deleteSession(String dateKey);
  Future<List<WorkoutSessionModel>> getHistory();
  
  Future<WeightUnit> getPreferredUnit();
  Future<void> setPreferredUnit(WeightUnit unit);
}

class WorkoutLocalDataSourceImpl implements WorkoutLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String historyKey = 'WORKOUT_HISTORY_V1';
  static const String unitPreferenceKey = 'WORKOUT_UNIT_PREFERENCE';

  WorkoutLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<WorkoutSessionModel?> getSessionForDate(String dateKey) async {
    final historyJson = sharedPreferences.getString(historyKey);
    if (historyJson == null) return null;

    final Map<String, dynamic> history = json.decode(historyJson);
    final sessionJson = history[dateKey];
    if (sessionJson == null) return null;

    return WorkoutSessionModel.fromJson(dateKey, sessionJson as Map<String, dynamic>);
  }

  @override
  Future<void> saveSession(WorkoutSessionModel session) async {
    final historyJson = sharedPreferences.getString(historyKey);
    final Map<String, dynamic> history = historyJson != null ? json.decode(historyJson) : {};

    history[session.dateKey] = session.toJson();
    await sharedPreferences.setString(historyKey, json.encode(history));
  }

  @override
  Future<void> deleteSession(String dateKey) async {
    final historyJson = sharedPreferences.getString(historyKey);
    if (historyJson == null) return;

    final Map<String, dynamic> history = json.decode(historyJson);
    if (history.containsKey(dateKey)) {
      history.remove(dateKey);
      await sharedPreferences.setString(historyKey, json.encode(history));
    }
  }

  @override
  Future<List<WorkoutSessionModel>> getHistory() async {
    final historyJson = sharedPreferences.getString(historyKey);
    if (historyJson == null) return [];

    final Map<String, dynamic> history = json.decode(historyJson);
    final sessions = history.entries.map((entry) {
      return WorkoutSessionModel.fromJson(entry.key, entry.value as Map<String, dynamic>);
    }).toList();

    // Sort by dateKey descending (newest first)
    sessions.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return sessions;
  }

  @override
  Future<WeightUnit> getPreferredUnit() async {
    final unitString = sharedPreferences.getString(unitPreferenceKey);
    if (unitString == null) return WeightUnit.kg;
    return WeightUnit.values.firstWhere(
      (e) => e.name == unitString,
      orElse: () => WeightUnit.kg,
    );
  }

  @override
  Future<void> setPreferredUnit(WeightUnit unit) async {
    await sharedPreferences.setString(unitPreferenceKey, unit.name);
  }
}

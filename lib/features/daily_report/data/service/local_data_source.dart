import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/model/daily_report.dart';

class LocalDataSource {
  final SharedPreferences _prefs;
  static const String _historyKey = 'report_history';

  LocalDataSource(this._prefs);

  Future<void> saveReport(DailyReport report) async {
    final history = await getReportHistory();
    // Use ID to either update or add new
    final existingIndex = history.indexWhere((r) => r.id == report.id);
    if (existingIndex != -1) {
      history[existingIndex] = report;
    } else {
      history.insert(0, report); // Newest first
    }

    final jsonList = history.map((r) => r.toJson()).toList();
    await _prefs.setString(_historyKey, json.encode(jsonList));
  }

  Future<List<DailyReport>> getReportHistory() async {
    final jsonString = _prefs.getString(_historyKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((j) => DailyReport.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteReport(String id) async {
    final history = await getReportHistory();
    history.removeWhere((r) => r.id == id);
    final jsonList = history.map((r) => r.toJson()).toList();
    await _prefs.setString(_historyKey, json.encode(jsonList));
  }
}

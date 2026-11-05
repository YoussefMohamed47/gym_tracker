import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../../domain/model/daily_report.dart';

/// Keeps today's in-progress report and the user's nutrition preferences in
/// the untyped preferences box, so a half-filled day survives an app restart.
///
/// The saved history (one record per shared report) is untouched: the draft is
/// only a working copy and is cleared once the report is shared.
class DailyReportDraftStore {
  static const _draftKey = 'daily_report_draft_v1';
  static const _draftDayKey = 'daily_report_draft_day_v1';
  static const _waterTargetKey = 'water_target_liters_v1';
  static const defaultWaterTargetLiters = 3.0;

  final Box _box;
  final DateTime Function() _now;

  DailyReportDraftStore(this._box, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Today's draft, or null when there is none or it belongs to another day.
  DailyReport? loadTodayDraft() {
    try {
      if (_box.get(_draftDayKey) != _dayKey(_now())) return null;
      final raw = _box.get(_draftKey);
      if (raw is! String || raw.isEmpty) return null;
      final report = DailyReport.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      return report.isEmpty ? null : report;
    } catch (e, st) {
      debugPrint('DailyReportDraftStore: draft unreadable, ignoring: $e\n$st');
      return null;
    }
  }

  Future<void> saveDraft(DailyReport report) async {
    if (report.isEmpty) return clearDraft();
    // One write, so the day and the draft can never be out of step.
    await _box.putAll({
      _draftDayKey: _dayKey(_now()),
      _draftKey: jsonEncode(report.toJson()),
    });
  }

  Future<void> clearDraft() async {
    await _box.deleteAll([_draftKey, _draftDayKey]);
  }

  double get waterTargetLiters {
    final value = _box.get(_waterTargetKey);
    return value is num && value > 0
        ? value.toDouble()
        : defaultWaterTargetLiters;
  }

  Future<void> setWaterTargetLiters(double liters) =>
      _box.put(_waterTargetKey, liters);
}

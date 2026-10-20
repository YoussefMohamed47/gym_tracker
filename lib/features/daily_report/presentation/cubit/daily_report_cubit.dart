import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/api_result.dart';
import '../../../workout/data/datasources/workout_catalog.dart';
import '../../../workout/domain/entities/workout_type.dart';
import '../../../workout/domain/repositories/workout_repository.dart';
import '../../../workout/utils/date_utils.dart';
import '../../domain/model/daily_report.dart';
import '../../domain/repository/daily_report_repository.dart';
import 'daily_report_state.dart';

class DailyReportCubit extends Cubit<DailyReportState> {
  final DailyReportRepository _repository;
  final WorkoutRepository? _workoutRepository;

  DailyReportCubit(
    this._repository, {
    this._workoutRepository,
  })  : super(DailyReportInitial()) {
    initTodayTrainingDefault();
  }

  Future<void> initTodayTrainingDefault() async {
    if (state.report.training.isNotEmpty || _workoutRepository == null) return;

    try {
      final now = DateTime.now();
      final dateKey = WorkoutDateUtils.formatDateKey(now);
      final session = await _workoutRepository!.getSessionForDate(dateKey);

      String defaultTraining;
      if (session != null) {
        defaultTraining = session.workoutType.displayName;
      } else {
        final history = await _workoutRepository!.getHistory();
        final pastTypes = history
            .where((s) => s.dateKey.compareTo(dateKey) < 0)
            .toList()
          ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

        final workoutTypes = pastTypes.map((s) => s.workoutType).toList();
        WorkoutType suggestedType;
        if (workoutTypes.isEmpty) {
          suggestedType = WorkoutDateUtils.getWorkoutTypeForDay(now);
        } else {
          final lastSessionDate = WorkoutDateUtils.parseDateKey(pastTypes.first.dateKey);
          final daysPassed = now.difference(lastSessionDate).inDays;
          suggestedType = workoutTypes.first;
          for (int i = 0; i < daysPassed; i++) {
            suggestedType = WorkoutCatalog.getNextWorkoutType([suggestedType, ...workoutTypes.skip(1)]);
            workoutTypes.insert(0, suggestedType);
          }
        }
        defaultTraining = suggestedType.displayName;
      }

      if (state.report.training.isEmpty) {
        emit(DailyReportUpdating(state.report.copyWith(training: defaultTraining)));
      }
    } catch (_) {
      // Fallback gracefully if repository or box is not initialized
    }
  }

  void updateField({
    String? breakfast,
    String? lunch,
    String? snack,
    String? beforeTraining,
    String? afterTraining,
    String? dinner,
    String? water,
    String? training,
    String? cardio,
    String? supplements,
    String? sleepTime,
    String? notes,
  }) {
    final updatedReport = state.report.copyWith(
      breakfast: breakfast,
      lunch: lunch,
      snack: snack,
      beforeTraining: beforeTraining,
      afterTraining: afterTraining,
      dinner: dinner,
      water: water,
      training: training,
      cardio: cardio,
      supplements: supplements,
      sleepTime: sleepTime,
      notes: notes,
    );
    emit(DailyReportUpdating(updatedReport));
  }

  void resetForm() {
    emit(DailyReportInitial());
    initTodayTrainingDefault();
  }

  void restoreReport(DailyReport report) {
    emit(DailyReportUpdating(report));
  }

  Future<void> generateAndCacheImage(Uint8List imageBytes) async {
    emit(DailyReportGeneratingImage(state.report));

    final cacheResult = await _repository.cacheReportImage(imageBytes);

    switch (cacheResult) {
      case ApiSuccess(data: final path):
        final finalReport = state.report.copyWith(
          dateTime: DateTime.now(),
          imagePath: path,
        );
        await _repository.saveReport(finalReport);
        emit(DailyReportSuccess(finalReport, path));
      case ApiFailure(failure: final failure):
        emit(DailyReportError(state.report, failure.message));
    }
  }
}

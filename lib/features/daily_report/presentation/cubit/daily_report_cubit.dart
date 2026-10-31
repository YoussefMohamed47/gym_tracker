import 'dart:typed_data';
import '../../domain/model/meal_entry.dart';
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
    if (_workoutRepository == null) return;

    try {
      final now = DateTime.now();
      final dateKey = WorkoutDateUtils.formatDateKey(now);
      final session = await _workoutRepository.getSessionForDate(dateKey);

      String defaultTraining;
      bool hasCompletedSession = false;

      if (session != null) {
        defaultTraining = session.workoutType.displayName;
        hasCompletedSession = true;
      } else {
        if (state.report.training.isNotEmpty) return; // Don't override if user set something manually and no session completed

        final history = await _workoutRepository.getHistory();
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

      if (state.report.training.isEmpty || hasCompletedSession) {
        if (state.report.training != defaultTraining) {
          emit(DailyReportUpdating(state.report.copyWith(training: defaultTraining)));
        }
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
    List<MealEntry>? breakfastEntries,
    List<MealEntry>? lunchEntries,
    List<MealEntry>? dinnerEntries,
    List<MealEntry>? snackEntries,
    List<MealEntry>? beforeTrainingEntries,
    List<MealEntry>? afterTrainingEntries,
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
      breakfastEntries: breakfastEntries,
      lunchEntries: lunchEntries,
      dinnerEntries: dinnerEntries,
      snackEntries: snackEntries,
      beforeTrainingEntries: beforeTrainingEntries,
      afterTrainingEntries: afterTrainingEntries,
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

  Future<void> copyFromYesterday() async {
    final result = await _repository.getReportHistory();
    if (result is ApiSuccess<List<DailyReport>>) {
      final history = result.data;
      if (history.isNotEmpty) {
        history.sort((a, b) {
          final dateA = a.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = b.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA);
        });
        
        final lastReport = history.first;
        
        final updatedReport = state.report.copyWith(
          breakfast: lastReport.breakfast,
          lunch: lastReport.lunch,
          snack: lastReport.snack,
          beforeTraining: lastReport.beforeTraining,
          afterTraining: lastReport.afterTraining,
          dinner: lastReport.dinner,
          water: lastReport.water,
          supplements: lastReport.supplements,
          sleepTime: lastReport.sleepTime,
          breakfastEntries: lastReport.breakfastEntries,
          lunchEntries: lastReport.lunchEntries,
          dinnerEntries: lastReport.dinnerEntries,
          snackEntries: lastReport.snackEntries,
          beforeTrainingEntries: lastReport.beforeTrainingEntries,
          afterTrainingEntries: lastReport.afterTrainingEntries,

        );
        emit(DailyReportUpdating(updatedReport));
      }
    }
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

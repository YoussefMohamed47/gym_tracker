import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/api_result.dart';
import '../../domain/model/daily_report.dart';
import '../../domain/repository/daily_report_repository.dart';
import 'daily_report_state.dart';

class DailyReportCubit extends Cubit<DailyReportState> {
  final DailyReportRepository _repository;

  DailyReportCubit(this._repository) : super(DailyReportInitial());

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

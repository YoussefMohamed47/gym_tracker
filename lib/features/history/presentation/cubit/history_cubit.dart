import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/api_result.dart';
import '../../../daily_report/domain/model/daily_report.dart';
import '../../../daily_report/domain/repository/daily_report_repository.dart';
import '../../../daily_report/domain/models/meal_adherence_data_point.dart';
import '../../../daily_report/domain/usecases/get_meal_adherence_usecase.dart';
import '../../../workout/domain/models/volume_data_point.dart';
import '../../../workout/domain/usecases/get_30_day_volume_usecase.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<DailyReport> reports;
  final VolumeTonnageReport? volumeReport;
  final List<MealAdherenceDataPoint>? mealAdherence;

  const HistoryLoaded({
    required this.reports,
    this.volumeReport,
    this.mealAdherence,
  });

  @override
  List<Object?> get props => [reports, volumeReport, mealAdherence];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class HistoryCubit extends Cubit<HistoryState> {
  final DailyReportRepository _repository;
  final Get30DayVolumeTonnageUseCase? get30DayVolume;
  final GetMealAdherenceUseCase? getMealAdherence;

  HistoryCubit(
    this._repository, {
    this.get30DayVolume,
    this.getMealAdherence,
  }) : super(HistoryInitial());

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    final result = await _repository.getReportHistory();
    VolumeTonnageReport? volumeReport;
    List<MealAdherenceDataPoint>? mealAdherence;

    final volumeUseCase = get30DayVolume;
    if (volumeUseCase != null) {
      try {
        volumeReport = await volumeUseCase.call();
      } catch (_) {
        // ignore analytics load error
      }
    }

    final adherenceUseCase = getMealAdherence;
    if (adherenceUseCase != null) {
      try {
        mealAdherence = await adherenceUseCase.call();
      } catch (_) {
        // ignore analytics load error
      }
    }

    switch (result) {
      case ApiSuccess(data: final history):
        emit(HistoryLoaded(reports: history, volumeReport: volumeReport, mealAdherence: mealAdherence));
      case ApiFailure(failure: final failure):
        emit(HistoryError(failure.message));
    }
  }

  Future<void> deleteReport(String id) async {
    final result = await _repository.deleteReport(id);
    if (result is ApiSuccess) {
      loadHistory();
    }
  }
}

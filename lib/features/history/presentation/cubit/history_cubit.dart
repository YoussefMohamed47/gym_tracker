import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/api_result.dart';
import '../../../daily_report/domain/model/daily_report.dart';
import '../../../daily_report/domain/repository/daily_report_repository.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}
class HistoryLoading extends HistoryState {}
class HistoryLoaded extends HistoryState {
  final List<DailyReport> reports;
  const HistoryLoaded(this.reports);
  @override
  List<Object?> get props => [reports];
}
class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class HistoryCubit extends Cubit<HistoryState> {
  final DailyReportRepository _repository;

  HistoryCubit(this._repository) : super(HistoryInitial());

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    final result = await _repository.getReportHistory();
    switch (result) {
      case ApiSuccess(data: final history):
        emit(HistoryLoaded(history));
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

import 'package:equatable/equatable.dart';
import '../../domain/model/daily_report.dart';

sealed class DailyReportState extends Equatable {
  final DailyReport report;

  const DailyReportState(this.report);

  @override
  List<Object?> get props => [report];
}

class DailyReportInitial extends DailyReportState {
  DailyReportInitial() : super(DailyReport.empty());
}

class DailyReportUpdating extends DailyReportState {
  const DailyReportUpdating(super.report);
}

class DailyReportGeneratingImage extends DailyReportState {
  const DailyReportGeneratingImage(super.report);
}

class DailyReportSuccess extends DailyReportState {
  final String imagePath;
  const DailyReportSuccess(super.report, this.imagePath);

  @override
  List<Object?> get props => [report, imagePath];
}

class DailyReportError extends DailyReportState {
  final String message;
  const DailyReportError(super.report, this.message);

  @override
  List<Object?> get props => [report, message];
}

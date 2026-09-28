import 'package:flutter/material.dart';
import '../../domain/model/daily_report.dart';
import 'daily_meals_report_card.dart';

class ReportImageTemplate extends StatelessWidget {
  final DailyReport report;
  final bool isExportMode;

  const ReportImageTemplate({
    super.key,
    required this.report,
    this.isExportMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return DailyMealsReportCard(
      report: report,
      isExportMode: isExportMode,
    );
  }
}

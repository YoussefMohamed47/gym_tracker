import 'package:flutter/material.dart';
import '../../../domain/entities/workout_session.dart';
import 'workout_complete_report_card.dart';

class WorkoutShareCard extends StatelessWidget {
  final WorkoutSession session;
  final bool isExportMode;

  const WorkoutShareCard({
    super.key,
    required this.session,
    this.isExportMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return WorkoutCompleteReportCard(
      session: session,
      isExportMode: isExportMode,
    );
  }
}

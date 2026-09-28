import 'package:flutter/material.dart';
import '../../../../core/utils/report_exporter.dart';
import '../../domain/entities/workout_session.dart';
import '../widgets/share/workout_complete_report_card.dart';

class WorkoutShareService {
  static Future<void> shareWorkout(
    BuildContext context,
    WorkoutSession session,
  ) async {
    try {
      await ReportExporter.captureAndShare(
        context: context,
        builder: (ctx) => WorkoutCompleteReportCard(
          session: session,
          isExportMode: true,
        ),
        fileName: 'workout_complete_${session.dateKey}',
        shareText:
            'Just finished my ${session.workoutType.name} workout! #GymTracker',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  static Future<void> saveToGallery(
    BuildContext context,
    WorkoutSession session,
  ) async {
    await shareWorkout(context, session);
  }
}

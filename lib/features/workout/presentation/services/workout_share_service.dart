import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../../../../core/utils/widget_image_capture.dart';
import '../../domain/entities/workout_session.dart';
import '../widgets/share/workout_share_card.dart';

class WorkoutShareService {
  static Future<void> shareWorkout(
    BuildContext context,
    WorkoutSession session,
  ) async {
    try {
      final bytes = await WidgetImageCapture.capture(
        context: context,
        child: WorkoutShareCard(session: session),
        width: 400,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/workout_${session.dateKey}.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Just finished my ${session.workoutType.name} workout! #GymTracker',
        ),
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
    try {
      final bytes = await WidgetImageCapture.capture(
        context: context,
        child: WorkoutShareCard(session: session),
        width: 400,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/workout_${session.dateKey}.png');
      await file.writeAsBytes(bytes);

      // Save to gallery using gal
      await Gal.putImage(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }
}

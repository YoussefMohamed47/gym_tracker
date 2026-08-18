import 'dart:io';
import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class SaveWorkoutSession {
  final WorkoutRepository repository;

  SaveWorkoutSession(this.repository);

  Future<void> call(WorkoutSession session) async {
    // 1. Fetch existing session to check for photos to delete
    final existingSession = await repository.getSessionForDate(session.dateKey);

    if (existingSession != null) {
      // Find photos that are in existing but NOT in new session
      final List<String> photosToDelete = [];

      for (final existingLog in existingSession.exerciseLogs.values) {
        final existingPath = existingLog.imagePath;
        if (existingPath != null && existingPath.isNotEmpty) {
          // Check if this path still exists in the new session
          bool stillReferenced = false;
          for (final newLog in session.exerciseLogs.values) {
            if (newLog.imagePath == existingPath) {
              stillReferenced = true;
              break;
            }
          }

          if (!stillReferenced) {
            photosToDelete.add(existingPath);
          }
        }
      }

      // Perform physical deletion
      for (final path in photosToDelete) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Log error or ignore if file can't be deleted
        }
      }
    }

    // 2. Save the new session
    await repository.saveSession(session);
  }
}

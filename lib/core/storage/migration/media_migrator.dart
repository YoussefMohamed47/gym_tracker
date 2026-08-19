import 'dart:io';
import 'package:path/path.dart' as p;

class MediaMigrator {
  final Directory appDocsDir;

  MediaMigrator({required this.appDocsDir});

  String get mediaDir => p.join(appDocsDir.path, 'media');

  /// Rescues a file from an absolute path to the persistent media directory.
  /// Returns the new relative path if successful, or null if it fails or source is missing.
  Future<String?> rescueFile(String? absolutePath) async {
    if (absolutePath == null || absolutePath.isEmpty) return null;

    final sourceFile = File(absolutePath);
    if (!await sourceFile.exists()) return null;

    // Check if already in persistent storage
    if (p.isWithin(appDocsDir.path, absolutePath)) {
      return p.relative(absolutePath, from: appDocsDir.path);
    }

    try {
      final fileName = p.basename(absolutePath);
      final targetDirectory = Directory(mediaDir);
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      final targetPath = p.join(mediaDir, fileName);
      await sourceFile.copy(targetPath);

      // Verify copy
      if (await File(targetPath).exists()) {
        return p.relative(targetPath, from: appDocsDir.path);
      }
    } catch (e) {
      // Log error in real implementation
    }

    return null;
  }
}

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/storage/migration/media_migrator.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late Directory appDocsDir;
  late MediaMigrator migrator;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('media_migrator_test');
    appDocsDir = Directory(p.join(tempDir.path, 'app_docs'));
    await appDocsDir.create();
    migrator = MediaMigrator(appDocsDir: appDocsDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('MediaMigrator Tests', () {
    test('Rescue file from external temp directory', () async {
      final externalTemp = Directory(p.join(tempDir.path, 'external_temp'));
      await externalTemp.create();
      final sourceFile = File(p.join(externalTemp.path, 'test.png'));
      await sourceFile.writeAsString('fake image');

      final relativePath = await migrator.rescueFile(sourceFile.path);

      expect(relativePath, isNotNull);
      expect(relativePath, p.join('media', 'test.png'));

      final targetFile = File(p.join(appDocsDir.path, relativePath!));
      expect(await targetFile.exists(), true);
    });

    test('Preserve relative reference if already in appDocs', () async {
      final internalMedia = Directory(
        p.join(appDocsDir.path, 'workout_photos'),
      );
      await internalMedia.create();
      final sourceFile = File(p.join(internalMedia.path, 'photo.jpg'));
      await sourceFile.writeAsString('fake photo');

      final relativePath = await migrator.rescueFile(sourceFile.path);

      expect(relativePath, p.join('workout_photos', 'photo.jpg'));
    });

    test('Return null if source missing', () async {
      final relativePath = await migrator.rescueFile('/non/existent/path.png');
      expect(relativePath, isNull);
    });
  });
}

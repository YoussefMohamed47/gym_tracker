import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class ImageService {
  Future<String> saveImageToCache(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/daily_report_$timestamp.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

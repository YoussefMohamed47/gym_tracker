import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (photo == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final workoutPhotosDir = Directory('${directory.path}/workout_photos');
      if (!await workoutPhotosDir.exists()) {
        await workoutPhotosDir.create(recursive: true);
      }

      final fileName = 'workout_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(
        photo.path,
      ).copy('${workoutPhotosDir.path}/$fileName');

      return savedImage.path;
    } catch (e) {
      return null;
    }
  }
}

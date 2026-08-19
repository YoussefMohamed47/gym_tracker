import 'package:url_launcher/url_launcher.dart';

class VideoLauncher {
  static Future<void> launch(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle or log error
    }
  }
}

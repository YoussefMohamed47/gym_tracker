import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/report_theme_tokens.dart';

class ReportExporter {
  /// Renders [builder] with `isExportMode = true` off-screen at fixed width 390.0 logical px
  /// with unbounded height, pixelRatio 3.0, opaque dark background (#0B0D12).
  /// Captures PNG image and opens share sheet via `share_plus`.
  static Future<void> captureAndShare({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
    required String fileName,
    String? shareText,
  }) async {
    final GlobalKey repaintKey = GlobalKey();
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -9999, // Render off-screen
        top: 0,
        child: Material(
          color: ReportThemeTokens.background,
          child: RepaintBoundary(
            key: repaintKey,
            child: SizedBox(
              width: 390.0, // Fixed width 390 logical px
              child: MediaQuery(
                data: const MediaQueryData(
                  disableAnimations: true,
                  devicePixelRatio: 3.0,
                ),
                child: builder(context),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    try {
      // Allow two frames for layout completion & image painting
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 120));

      final boundary = repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate image byte data');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: shareText ?? 'Shared via Gym Tracker',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share report: $e')),
        );
      }
    } finally {
      entry.remove();
    }
  }
}

// lib/core/utils/widget_image_capture.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetImageCapture {
  /// Renders [child] off-screen at a fixed [width] with UNBOUNDED height,
  /// so it lays out at its true full size (however tall the content is)
  /// instead of being squeezed into the device's screen size. Captures
  /// the entire painted content as a PNG, nothing cropped or overflowed.
  static Future<Uint8List> capture({
    required BuildContext context,
    required Widget child,
    double width = 400,
    double pixelRatio = 2.0,
  }) async {
    final repaintKey = GlobalKey();
    final overlay = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -9999, // off-screen, never visible to the user
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: repaintKey,
            child: SizedBox(width: width, child: child), // height: unbounded
          ),
        ),
      ),
    );

    overlay.insert(entry);

    try {
      // Two frames: one to build, one to guarantee paint has completed.
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } finally {
      entry.remove();
    }
  }
}
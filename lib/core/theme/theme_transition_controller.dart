import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'circular_reveal_clipper.dart';

class ThemeTransitionController {
  final GlobalKey boundaryKey = GlobalKey();
  bool _isTransitioning = false;

  Future<void> animateThemeToggle({
    required BuildContext context,
    required GlobalKey buttonKey,
    required VoidCallback onToggle,
  }) async {
    if (_isTransitioning) return;

    // Respect reduced motion
    if (MediaQuery.of(context).disableAnimations) {
      onToggle();
      return;
    }

    _isTransitioning = true;

    try {
      // 1. Resolve button center
      final RenderBox? buttonBox =
          buttonKey.currentContext?.findRenderObject() as RenderBox?;
      if (buttonBox == null) {
        onToggle();
        _isTransitioning = false;
        return;
      }
      final Offset center = buttonBox.localToGlobal(
        buttonBox.size.center(Offset.zero),
      );

      // 2. Capture current frame (OLD theme)
      final RenderRepaintBoundary? boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        onToggle();
        _isTransitioning = false;
        return;
      }

      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      // 3. Insert transition overlay
      final overlayState = Overlay.of(context);
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) => _ThemeTransitionOverlay(
          image: image,
          center: center,
          onComplete: () {
            entry.remove();
            image.dispose();
            _isTransitioning = false;
          },
        ),
      );

      overlayState.insert(entry);

      // 4. Trigger the actual theme change underneath
      onToggle();
    } catch (e) {
      debugPrint('Theme transition failed: $e');
      onToggle();
      _isTransitioning = false;
    }
  }
}

class _ThemeTransitionOverlay extends StatefulWidget {
  final ui.Image image;
  final Offset center;
  final VoidCallback onComplete;

  const _ThemeTransitionOverlay({
    required this.image,
    required this.center,
    required this.onComplete,
  });

  @override
  State<_ThemeTransitionOverlay> createState() =>
      _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<_ThemeTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;

    // Calculate max radius to cover the furthest screen corner
    final maxRadius = _calculateMaxRadius(widget.center, size);

    _radiusAnimation = Tween<double>(begin: 0, end: maxRadius).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward();
  }

  double _calculateMaxRadius(Offset center, Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];

    double maxDist = 0;
    for (final corner in corners) {
      final dist = (center - corner).distance;
      if (dist > maxDist) maxDist = dist;
    }
    return maxDist;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _radiusAnimation,
      builder: (context, child) {
        return ClipPath(
          clipper: CircularRevealClipper(
            center: widget.center,
            radius: _radiusAnimation.value,
          ),
          child: RawImage(
            image: widget.image,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
        );
      },
    );
  }
}

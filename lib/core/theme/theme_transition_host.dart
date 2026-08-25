import 'package:flutter/material.dart';
import 'theme_transition_controller.dart';

class ThemeTransitionHost extends StatelessWidget {
  final Widget child;
  final ThemeTransitionController controller;

  const ThemeTransitionHost({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller.boundaryKey,
      child: child,
    );
  }
}

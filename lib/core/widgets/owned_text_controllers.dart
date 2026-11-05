import 'package:flutter/material.dart';

/// Creates text controllers for a bottom sheet or dialog and disposes them
/// only when that route's widgets are really gone.
///
/// Disposing a controller right after `await showModalBottomSheet(...)` is a
/// bug: the future completes when the sheet starts closing, but its text
/// fields are still drawn during the closing animation, which throws
/// "A TextEditingController was used after being disposed".
class OwnedTextControllers extends StatefulWidget {
  final List<String> initialTexts;
  final Widget Function(
    BuildContext context,
    List<TextEditingController> controllers,
  )
  builder;

  const OwnedTextControllers({
    super.key,
    required this.initialTexts,
    required this.builder,
  });

  @override
  State<OwnedTextControllers> createState() => _OwnedTextControllersState();
}

class _OwnedTextControllersState extends State<OwnedTextControllers> {
  late final List<TextEditingController> _controllers = [
    for (final text in widget.initialTexts) TextEditingController(text: text),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controllers);
}

import 'package:flutter/widgets.dart';

/// Open/closed state for a foldable section. It follows [shouldFold] until
/// [toggle] is called; that choice then holds until [resetKey] changes.
class AutoFold extends StatefulWidget {
  final bool shouldFold;

  /// When this changes (e.g. the day shown), a manual choice is forgotten.
  final Object? resetKey;

  final Widget Function(
    BuildContext context,
    bool isExpanded,
    VoidCallback toggle,
  )
  builder;

  const AutoFold({
    super.key,
    required this.shouldFold,
    required this.resetKey,
    required this.builder,
  });

  @override
  State<AutoFold> createState() => _AutoFoldState();
}

class _AutoFoldState extends State<AutoFold> {
  bool? _userExpanded;

  @override
  void didUpdateWidget(AutoFold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetKey != widget.resetKey) _userExpanded = null;
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = _userExpanded ?? !widget.shouldFold;
    return widget.builder(
      context,
      isExpanded,
      () => setState(() => _userExpanded = !isExpanded),
    );
  }
}

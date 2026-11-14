import 'package:flutter/widgets.dart';

/// Calls [onResumed] each time the app comes back to the foreground.
class AppResumeListener extends StatefulWidget {
  final VoidCallback onResumed;
  final Widget child;

  const AppResumeListener({
    super.key,
    required this.onResumed,
    required this.child,
  });

  @override
  State<AppResumeListener> createState() => _AppResumeListenerState();
}

class _AppResumeListenerState extends State<AppResumeListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.onResumed();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/core/widgets/app_resume_listener.dart';

void main() {
  testWidgets('calls onResumed when the app returns to the foreground', (
    tester,
  ) async {
    var resumed = 0;
    await tester.pumpWidget(
      AppResumeListener(onResumed: () => resumed++, child: const SizedBox()),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(resumed, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(resumed, 1);
  });

  testWidgets('stops listening once removed', (tester) async {
    var resumed = 0;
    await tester.pumpWidget(
      AppResumeListener(onResumed: () => resumed++, child: const SizedBox()),
    );
    await tester.pumpWidget(const SizedBox());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(resumed, 0);
  });
}

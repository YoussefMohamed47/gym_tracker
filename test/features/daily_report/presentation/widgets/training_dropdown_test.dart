import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/app_theme.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/widgets/daily_report_form.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('training dropdown follows outside changes to the report', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final notifier = ValueNotifier(
      DailyReport.empty().copyWith(training: 'Chest & Back'),
    );
    const options = ['Chest & Back', 'Shoulder & Arms', 'Legs', 'Cardio'];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ValueListenableBuilder<DailyReport>(
              valueListenable: notifier,
              builder: (context, report, _) => DailyReportForm(
                key: ValueKey(report.id),
                report: report,
                trainingOptions: options,
                onWaterTargetChanged: (_) {},
                onChanged: (r) => notifier.value = r,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    String? displayed() => tester
        .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .value;

    expect(displayed(), 'Chest & Back');

    // The Workout tab switches the day: the report changes from outside.
    notifier.value = notifier.value.copyWith(training: 'Legs');
    await tester.pump();
    expect(displayed(), 'Legs');
    expect(find.text('Legs'), findsWidgets);

    // A name that is not in the plan list (e.g. an older "Push" day) still shows.
    notifier.value = notifier.value.copyWith(training: 'Push');
    await tester.pump();
    expect(displayed(), 'Push');
    expect(find.text('Push'), findsWidgets);
    final error = tester.takeException();
    expect(
      error == null || error.toString().contains('GoogleFonts'),
      isTrue,
      reason: '$error',
    );
  });
}

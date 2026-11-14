import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/app_theme.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/widgets/daily_report_form.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const rotation = ['Chest & Back', 'Shoulder & Arms', 'Legs', 'Rest Day'];

  Future<void> openDropdown(WidgetTester tester, String training) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DailyReportForm(
              report: DailyReport.empty().copyWith(training: training),
              onChanged: (_) {},
              trainingOptions: [...rotation, 'Cardio'],
              onWaterTargetChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    tester.takeException(); // Missing fonts in tests only.
  }

  List<String> menuTexts(WidgetTester tester) => [
    for (final item in tester.widgetList<DropdownMenuItem<String>>(
      find.byType(DropdownMenuItem<String>),
    ))
      if (item.child is Text) (item.child as Text).data!,
  ];

  testWidgets('8-day days come first, then Other and Cardio', (tester) async {
    // Nothing picked, so the button itself doesn't list a day first.
    await openDropdown(tester, '');

    final texts = menuTexts(tester).toSet().toList();
    expect(texts, [...rotation, 'OTHER', 'Cardio']);
  });

  testWidgets('an old-plan day is kept but labelled', (tester) async {
    await openDropdown(tester, 'Push');

    expect(menuTexts(tester), contains('Push (old plan)'));
  });

  testWidgets('the Other heading cannot be picked', (tester) async {
    await openDropdown(tester, 'Legs');

    final header = tester
        .widgetList<DropdownMenuItem<String>>(
          find.byType(DropdownMenuItem<String>),
        )
        .firstWhere((i) => (i.child as Text).data == 'OTHER');
    expect(header.enabled, isFalse);
  });

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

    // A name that is not in the plan list (an older "Push" day) still shows,
    // labelled as coming from the old plan.
    notifier.value = notifier.value.copyWith(training: 'Push');
    await tester.pump();
    expect(displayed(), 'Push');
    expect(find.text('Push (old plan)'), findsWidgets);
    final error = tester.takeException();
    expect(
      error == null || error.toString().contains('GoogleFonts'),
      isTrue,
      reason: '$error',
    );
  });
}

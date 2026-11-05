import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/app_theme.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/meal_entry.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/meal_slot.dart';
import 'package:gym_tracker_report/features/daily_report/domain/models/nutrition_insights.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/widgets/daily_report_form.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/widgets/today_summary_card.dart';

const _chicken = MealEntry(
  name: 'صدر دجاج مشوي',
  category: 'بروتين',
  quantity: 180,
  unit: 'جم',
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  // Google Fonts can't load offline in tests; that is not a layout problem.
  bool onlyFontErrors(WidgetTester tester) {
    final e = tester.takeException();
    return e == null || e.toString().contains('GoogleFonts');
  }

  for (final dark in [true, false]) {
    testWidgets('Nutrition widgets lay out on a phone (dark: $dark)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var report = DailyReport.empty().copyWith(
        water: '2 لتر',
        training: 'Chest & Back',
        supplements: 'Creatine',
        breakfastEntries: const [_chicken],
      );
      const insights = NutritionInsights(
        streakDays: 12,
        lastSevenDays: [true, true, true, true, true, true, false],
        usualMeals: {
          MealSlot.lunch: [_chicken],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TodaySummaryCard(
                      report: report,
                      insights: insights,
                      waterTargetLiters: 3,
                    ),
                    DailyReportForm(
                      report: report,
                      trainingOptions: const ['Chest & Back', 'Legs'],
                      usualMeals: insights.usualMeals,
                      onWaterTargetChanged: (_) {},
                      onChanged: (r) => setState(() => report = r),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(onlyFontErrors(tester), isTrue);

      // Breakfast is logged, so the form opens on lunch with the usual-meal chip.
      expect(find.text('NOW'), findsOneWidget);
      expect(find.text('Your usual lunch'), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget); // meals ring
      expect(find.text('12-day streak'), findsOneWidget);

      // +250 updates the water text through the normal onChanged path.
      await tester.tap(find.text('+250'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(report.water, '2.25 لتر');

      // "Use" fills lunch from history.
      await tester.tap(find.text('Use'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(report.lunchEntries, const [_chicken]);
      expect(onlyFontErrors(tester), isTrue);
    });
  }
}

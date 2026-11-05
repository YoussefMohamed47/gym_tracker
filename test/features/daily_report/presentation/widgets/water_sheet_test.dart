import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/app_theme.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/widgets/water_quick_add_card.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  bool onlyFontErrors(WidgetTester tester) {
    final e = tester.takeException();
    return e == null || e.toString().contains('GoogleFonts');
  }

  testWidgets(
    'water sheet saves values and closes without disposed-controller errors',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      String? text;
      double? target;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: WaterQuickAddCard(
                waterText: '1 لتر',
                targetLiters: 3,
                onAdd: (_) {},
                onSetText: (t) => text = t,
                onSetTarget: (t) => target = t,
              ),
            ),
          ),
        ),
      );

      // Open, change both values, save; let the closing animation finish.
      await tester.tap(find.text('1.0 L'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.enterText(find.byType(TextField).first, '2.5 لتر');
      await tester.enterText(find.byType(TextField).last, '3.5');
      await tester.tap(find.text('حفظ'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(onlyFontErrors(tester), isTrue);
      expect(text, '2.5 لتر');
      expect(target, 3.5);

      // Open again and dismiss by tapping outside: nothing is saved.
      text = null;
      await tester.tap(find.text('1.0 L'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tapAt(const Offset(180, 20));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(onlyFontErrors(tester), isTrue);
      expect(text, isNull);
    },
  );
}

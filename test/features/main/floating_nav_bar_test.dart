import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/app_theme.dart';
import 'package:gym_tracker_report/features/main/presentation/widgets/floating_nav_bar.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final dark in [true, false]) {
    testWidgets('nav bar lays out and switches tabs (dark: $dark)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              bottomNavigationBar: FloatingNavBar(
                selectedIndex: selected,
                onDestinationSelected: (i) => setState(() => selected = i),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Nutrition'), findsOneWidget);
      expect(find.text('Workout'), findsOneWidget);

      // The selected capsule fills the pill: 62 tall, minus 5 padding and the
      // 1 px border on each side.
      final capsule = tester.getSize(
        find
            .ancestor(
              of: find.text('Nutrition'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(capsule.height, 50);

      await tester.tap(find.text('Workout'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(selected, 1);

      final error = tester.takeException();
      expect(
        error == null || error.toString().contains('GoogleFonts'),
        isTrue,
        reason: '$error',
      );
    });
  }
}

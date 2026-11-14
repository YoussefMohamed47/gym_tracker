import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/widgets/water_quick_add_card.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<List<double>> pumpCard(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    final added = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: WaterQuickAddCard(
                waterText: '0',
                targetLiters: 3,
                onAdd: added.add,
                onSetText: (_) {},
                onSetTarget: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    tester.takeException(); // Missing fonts in tests only.
    return added;
  }

  testWidgets('adding water floats "+250 ml" up, then clears it', (
    tester,
  ) async {
    final added = await pumpCard(tester);

    await tester.tap(find.text('+250'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(added, [0.25]);
    expect(find.text('+250 ml'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('+250 ml'), findsNothing);
  });

  testWidgets('no float with reduced motion; water is still added', (
    tester,
  ) async {
    final added = await pumpCard(tester, reduceMotion: true);

    await tester.tap(find.text('+500'));
    await tester.pump();

    expect(added, [0.5]);
    expect(find.text('+500 ml'), findsNothing);
  });
}

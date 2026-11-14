import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/widgets/bilingual_label.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('shows Arabic first and English in capitals below', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BilingualLabel(arabic: 'زندروس', english: 'Zandros'),
        ),
      ),
    );
    tester.takeException(); // Missing fonts in tests only.

    final arabic = tester.getTopLeft(find.text('زندروس'));
    final english = tester.getTopLeft(find.text('ZANDROS'));
    expect(english.dy, greaterThan(arabic.dy));
  });
}

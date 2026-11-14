import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/set_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(
    WidgetTester tester,
    ExerciseSetLog? previous, {
    bool weightAllowed = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(360, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SetRow(
            index: 0,
            // Values here so the steppers don't show their own "—".
            setLog: const ExerciseSetLog(weightKg: 50, actualReps: 8),
            previousSetLog: previous,
            displayUnit: WeightUnit.kg,
            isWeightAllowed: weightAllowed,
            onWeightChanged: (_) {},
            onRepsChanged: (_) {},
            onTogglePerformed: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows last time as weight×reps', (tester) async {
    await pump(
      tester,
      const ExerciseSetLog(weightKg: 62.5, actualReps: 10, isPerformed: true),
    );

    expect(find.text('62.5×10'), findsOneWidget);
  });

  testWidgets('shows only reps when weight does not apply', (tester) async {
    await pump(
      tester,
      const ExerciseSetLog(weightKg: 20, actualReps: 12, isPerformed: true),
      weightAllowed: false,
    );

    expect(find.text('×12'), findsOneWidget);
  });

  testWidgets('keeps the unit on a weight with no reps', (tester) async {
    await pump(tester, const ExerciseSetLog(weightKg: 60, isPerformed: true));

    expect(find.text('60kg'), findsOneWidget);
  });

  testWidgets('shows a dash with no last time', (tester) async {
    await pump(tester, null);

    expect(find.text('—'), findsOneWidget);
  });
}

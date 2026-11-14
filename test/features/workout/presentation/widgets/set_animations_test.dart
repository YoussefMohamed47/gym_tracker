import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/last_time_panel.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/number_stepper.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/set_row.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpRow(
    WidgetTester tester, {
    bool done = false,
    bool active = false,
    bool settle = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(360, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SetRow(
            index: 1,
            setLog: ExerciseSetLog(
              weightKg: 50,
              actualReps: 8,
              isPerformed: done,
            ),
            displayUnit: WeightUnit.kg,
            isActive: active,
            onWeightChanged: (_) {},
            onRepsChanged: (_) {},
            onTogglePerformed: () {},
          ),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  double sweep(WidgetTester tester) => tester
      .widget<AnimatedFractionallySizedBox>(
        find.byType(AnimatedFractionallySizedBox),
      )
      .widthFactor!;

  testWidgets('a ticked set is filled across the row', (tester) async {
    await pumpRow(tester, done: true);
    expect(sweep(tester), 1);
  });

  testWidgets('an unticked set has no fill', (tester) async {
    await pumpRow(tester);
    expect(sweep(tester), 0);
  });

  testWidgets('becoming the next set pops without rebuilding the row', (
    tester,
  ) async {
    await pumpRow(tester);
    final stepperBefore = tester.state(find.byType(NumberStepper).first);
    double scale() => tester
        .widget<ScaleTransition>(
          find
              .ancestor(
                of: find.byType(AnimatedContainer).first,
                matching: find.byType(ScaleTransition),
              )
              .first,
        )
        .scale
        .value;
    expect(scale(), 1);

    await pumpRow(tester, active: true, settle: false);
    await tester.pump(const Duration(milliseconds: 40));
    expect(scale(), lessThan(1), reason: 'popping in');
    expect(
      tester.state(find.byType(NumberStepper).first),
      same(stepperBefore),
      reason: 'steppers keep their state (e.g. a held +)',
    );

    await tester.pumpAndSettle();
    expect(scale(), closeTo(1, 0.001));
  });

  Future<void> pumpPanel(WidgetTester tester, double todayKg) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LastTimePanel(
            previousDate: 'LAST WEEK',
            previousSets: const [
              ExerciseSetLog(weightKg: 60, actualReps: 10, isPerformed: true),
            ],
            currentSets: [
              ExerciseSetLog(
                weightKg: todayKg,
                actualReps: 10,
                isPerformed: true,
              ),
            ],
            unit: WeightUnit.kg,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Last time pulses once today beats it', (tester) async {
    await pumpPanel(tester, 65);
    expect(find.byType(Animate), findsOneWidget);
  });

  testWidgets('Last time stays still when today is not better', (tester) async {
    await pumpPanel(tester, 55);
    expect(find.byType(Animate), findsNothing);
  });
}

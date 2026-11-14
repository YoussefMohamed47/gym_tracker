import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/animations.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_state.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/workout_header.dart';

// A rest day keeps the header off the rotation lookup, so no DI is needed.
WorkoutState _withDone(int done, {String dateKey = '2026-11-14'}) =>
    WorkoutState.initial().copyWith(
      dateKey: dateKey,
      workoutType: WorkoutType.rest,
      exerciseLogs: {
        'routine': ExerciseLog(
          plannedExerciseId: 'routine',
          performedExerciseId: 'routine',
          sets: [
            for (var i = 0; i < 10; i++) ExerciseSetLog(isPerformed: i < done),
          ],
          timestamp: DateTime(2026, 11, 14),
        ),
      },
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(
    WidgetTester tester,
    WorkoutState state, {
    bool reduceMotion = false,
  }) => tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          body: SingleChildScrollView(
            child: WorkoutHeader(state: state, onTypeTapped: () {}),
          ),
        ),
      ),
    ),
  );

  testWidgets('counts up to the new number of done sets', (tester) async {
    await pump(tester, _withDone(0));
    expect(find.text('0'), findsOneWidget);

    await pump(tester, _withDone(8));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('8'), findsNothing, reason: 'still counting');

    await tester.pumpAndSettle();
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('another day shows its own count without counting', (
    tester,
  ) async {
    await pump(tester, _withDone(8));
    await pump(tester, _withDone(0, dateKey: '2026-11-13'));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('jumps straight to the number with reduced motion', (
    tester,
  ) async {
    await pump(tester, _withDone(0), reduceMotion: true);
    await pump(tester, _withDone(8), reduceMotion: true);
    await tester.pump();

    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('motion() is zero only when reduced motion is on', (
    tester,
  ) async {
    late Duration normal;
    late Duration reduced;
    const d = Duration(milliseconds: 240);
    await tester.pumpWidget(
      Column(
        children: [
          Builder(
            builder: (context) {
              normal = context.motion(d);
              return const SizedBox();
            },
          ),
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                reduced = context.motion(d);
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );

    expect(normal, d);
    expect(reduced, Duration.zero);
  });
}

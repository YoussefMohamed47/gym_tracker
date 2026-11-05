import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/app_theme.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_catalog.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/exercise_card.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final dark in [true, false]) {
    testWidgets('focused exercise card lays out on a phone (dark: $dark)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final slot = WorkoutCatalog.getWorkoutByType(
        WorkoutType.chestAndBack,
      )!.exercises.first;
      final log = ExerciseLog(
        plannedExerciseId: slot.exerciseId,
        performedExerciseId: slot.exerciseId,
        sets: const [
          ExerciseSetLog(weightKg: 62.5, actualReps: 10, isPerformed: true),
          ExerciseSetLog(weightKg: 65, actualReps: 8, isPerformed: true),
          ExerciseSetLog(weightKg: 62.5, actualReps: 9, isPerformed: false),
        ],
        isPerformed: false,
        timestamp: DateTime(2026, 11, 5),
        displayUnit: WeightUnit.kg,
      );
      const previous = [
        ExerciseSetLog(weightKg: 60, actualReps: 10, isPerformed: true),
        ExerciseSetLog(weightKg: 60, actualReps: 10, isPerformed: true),
        ExerciseSetLog(weightKg: 60, actualReps: 8, isPerformed: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExerciseCard(
                log: log,
                slot: slot,
                displayUnit: WeightUnit.kg,
                isExpanded: true,
                positionLabel: 'EXERCISE 1 OF 6',
                previousDate: '7 DAYS AGO',
                previousSets: previous,
                onExpandToggle: () {},
                onWeightChanged: (_, _) {},
                onRepsChanged: (_, _) {},
                onToggleSetPerformed: (_) {},
                onUnitChanged: (_) {},
                onSelectAlternative: () {},
                onAddPhoto: () {},
                onShowHistory: () {},
                onCopyPreviousSession: () {},
                onAddSet: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      final error = tester.takeException();
      expect(
        error == null || error.toString().contains('GoogleFonts'),
        isTrue,
        reason: '$error',
      );

      expect(find.text('EXERCISE 1 OF 6'), findsOneWidget);
      expect(find.text('LAST TIME · 7 DAYS AGO'), findsOneWidget);
      expect(find.text('60 kg × 10, 10, 8'), findsOneWidget);
      expect(find.text('New weight PR!'), findsOneWidget);
    });
  }
}

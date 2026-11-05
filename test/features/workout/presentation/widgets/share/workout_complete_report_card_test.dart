import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/utils/weight_converter.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_catalog.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_session.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/share/exercise_report_card.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/share/workout_complete_report_card.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('legs report renders every performed main lift from legs_8day', (
    tester,
  ) async {
    final legs = WorkoutCatalog.getWorkoutByType(WorkoutType.legs)!;
    final logs = {
      for (final slot in legs.exercises)
        slot.exerciseId: ExerciseLog(
          plannedExerciseId: slot.exerciseId,
          performedExerciseId: slot.exerciseId,
          isPerformed: true,
          timestamp: DateTime(2026, 11, 2),
        ),
    };
    final session = WorkoutSession(
      dateKey: '2026-11-02',
      workoutType: WorkoutType.legs,
      exerciseLogs: logs,
      displayUnit: WeightUnit.kg,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: WorkoutCompleteReportCard(
            session: session,
            isExportMode: true,
          ),
        ),
      ),
    );

    expect(
      find.byType(ExerciseReportCard, skipOffstage: false),
      findsNWidgets(legs.exercises.length),
    );
  });
}

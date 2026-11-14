import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_tracker_report/core/error/api_result.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_catalog.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/exercise_set_log.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/domain/repositories/workout_repository.dart';
import 'package:gym_tracker_report/features/workout/domain/usecases/get_previous_exercise_log.dart';
import 'package:gym_tracker_report/features/workout/domain/usecases/save_workout_session.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_cubit.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_state.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/routine_section.dart';
import 'package:mocktail/mocktail.dart';

class _MockWorkoutRepository extends Mock implements WorkoutRepository {}

ExerciseLog _log(String id, {int done = 0}) => ExerciseLog(
  plannedExerciseId: id,
  performedExerciseId: id,
  sets: [for (var i = 0; i < 2; i++) ExerciseSetLog(isPerformed: i < done)],
  timestamp: DateTime(2026, 11, 14),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late WorkoutCubit cubit;
  final mainId = WorkoutCatalog.getWorkoutByType(
    WorkoutType.push,
  )!.exercises.first.exerciseId;
  final routine = WorkoutCatalog.getDailyRoutine().exercises;
  final firstRoutineName = WorkoutCatalog.getExerciseById(
    routine.first.exerciseId,
  ).name;

  void showDay(String dateKey, {int mainDone = 0}) {
    cubit.emit(
      cubit.state.copyWith(
        status: WorkoutStatus.success,
        dateKey: dateKey,
        workoutType: WorkoutType.push,
        mainExerciseIds: [mainId],
        exerciseLogs: {
          mainId: _log(mainId, done: mainDone),
          for (final slot in routine) slot.exerciseId: _log(slot.exerciseId),
        },
      ),
    );
  }

  setUp(() {
    final repository = _MockWorkoutRepository();
    when(
      () => repository.getLastPerformedExerciseLogs(
        any(),
        beforeDateKey: any(named: 'beforeDateKey'),
      ),
    ).thenAnswer((_) async => const ApiSuccess({}));
    cubit = WorkoutCubit(
      repository: repository,
      getPreviousExerciseLog: GetPreviousExerciseLog(repository),
      saveWorkoutSession: SaveWorkoutSession(repository),
      autoSaveDelay: null,
    );
  });

  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider.value(
            value: cubit,
            child: const RoutineSection(),
          ),
        ),
      ),
    ),
  );

  testWidgets('stays open before the main lifts start', (tester) async {
    showDay('2026-11-14');
    await pump(tester);

    expect(find.text(firstRoutineName), findsOneWidget);
  });

  testWidgets('folds once a main-lift set is ticked', (tester) async {
    showDay('2026-11-14');
    await pump(tester);

    showDay('2026-11-14', mainDone: 1);
    await tester.pumpAndSettle();

    expect(find.text(firstRoutineName), findsNothing);
  });

  testWidgets('a tap reopens it, until the next day', (tester) async {
    showDay('2026-11-14', mainDone: 1);
    await pump(tester);

    await tester.tap(find.text('Warm-up & Rehab (Daily Routine)'));
    await tester.pumpAndSettle();
    expect(find.text(firstRoutineName), findsOneWidget);

    showDay('2026-11-15', mainDone: 1);
    await tester.pumpAndSettle();
    expect(find.text(firstRoutineName), findsNothing);
  });
}

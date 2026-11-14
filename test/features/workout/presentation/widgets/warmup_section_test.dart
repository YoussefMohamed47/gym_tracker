import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'package:gym_tracker_report/features/workout/presentation/widgets/set_check_button.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/warmup_section.dart';
import 'package:mocktail/mocktail.dart';

class _MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final warmup = WorkoutCatalog.getUpperBodyWarmup().exercises;
  late WorkoutCubit cubit;

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
    cubit.emit(
      cubit.state.copyWith(
        status: WorkoutStatus.success,
        dateKey: '2026-11-14',
        workoutType: WorkoutType.push,
        exerciseLogs: {
          for (final slot in warmup)
            slot.exerciseId: ExerciseLog(
              plannedExerciseId: slot.exerciseId,
              performedExerciseId: slot.exerciseId,
              sets: [
                for (var i = 0; i < slot.prescribedSets; i++)
                  const ExerciseSetLog(),
              ],
              timestamp: DateTime(2026, 11, 14),
            ),
        },
      ),
    );
  });

  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BlocProvider.value(
              value: cubit,
              child: const WarmupSection(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('uses one large set button per warm-up set', (tester) async {
    await pump(tester);

    final totalSets = warmup.fold<int>(0, (n, s) => n + s.prescribedSets);
    expect(find.byType(SetCheckButton), findsNWidgets(totalSets));
    expect(tester.getSize(find.byType(SetCheckButton).first).height, 48);
  });

  testWidgets('screen readers get one tappable node per set', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    final node = find.semantics.byLabel('Set 1').evaluate().first;
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    // The visible "S1" text is not announced as a second node.
    expect(find.semantics.byLabel('S1').evaluate(), isEmpty);

    tester.semantics.tap(find.semantics.byLabel('Set 1').first);
    await tester.pumpAndSettle();
    final first = warmup.first.exerciseId;
    expect(cubit.state.exerciseLogs[first]!.sets.first.isPerformed, isTrue);
    handle.dispose();
  });

  testWidgets('tapping a set button ticks that set', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(SetCheckButton).first);
    await tester.pumpAndSettle();

    final first = warmup.first.exerciseId;
    expect(cubit.state.exerciseLogs[first]!.sets.first.isPerformed, isTrue);
  });
}

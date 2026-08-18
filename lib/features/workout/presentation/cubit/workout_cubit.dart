import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../utils/date_utils.dart';
import 'workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutRepository repository;

  WorkoutCubit({required this.repository}) : super(WorkoutState.initial());

  Future<void> loadDate(DateTime date) async {
    emit(state.copyWith(status: WorkoutStatus.loading, selectedDate: date));

    final dateKey = WorkoutDateUtils.formatDateKey(date);
    final workoutType = WorkoutDateUtils.getWorkoutTypeForDay(date);
    final preferredUnit = await repository.getPreferredUnit();

    try {
      final session = await repository.getSessionForDate(dateKey);

      if (session != null) {
        emit(state.copyWith(
          status: WorkoutStatus.success,
          dateKey: dateKey,
          workoutType: session.workoutType,
          exerciseLogs: session.exerciseLogs,
          displayUnit: session.displayUnit,
          isEditMode: true,
        ));
      } else {
        // No session found, initialize draft from catalog and prefill
        final workoutDef = WorkoutCatalog.getWorkoutForDate(date);
        final Map<String, ExerciseLog> logs = {};

        if (workoutDef != null) {
          for (final slot in workoutDef.exercises) {
            // Check for previous performance for prefill
            final prevLog = await repository.getPreviousExerciseLog(
              workoutType.name,
              slot.exerciseId,
            );

            logs[slot.exerciseId] = ExerciseLog(
              plannedExerciseId: slot.exerciseId,
              performedExerciseId: slot.exerciseId,
              weightKg: prevLog?.weightKg,
              isPerformed: false,
              timestamp: DateTime.now(),
            );
          }
        }

        emit(state.copyWith(
          status: WorkoutStatus.success,
          dateKey: dateKey,
          workoutType: workoutType,
          exerciseLogs: logs,
          displayUnit: preferredUnit,
          isEditMode: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: WorkoutStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateWeight(String exerciseId, double? weight, WeightUnit unit) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[exerciseId];

    if (log != null) {
      final weightKg = weight != null
          ? WeightConverter.convert(weight, unit, WeightUnit.kg)
          : null;

      logs[exerciseId] = log.copyWith(
        weightKg: weightKg,
        isPerformed: weight != null, // Auto-mark as performed if weight is entered
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(exerciseLogs: logs));
    }
  }

  void togglePerformed(String exerciseId) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[exerciseId];

    if (log != null) {
      logs[exerciseId] = log.copyWith(isPerformed: !log.isPerformed);
      emit(state.copyWith(exerciseLogs: logs));
    }
  }

  void selectAlternative(String originalId, String alternativeId) async {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[originalId];

    if (log != null) {
      // If switching to an alternative, we might want to prefill its history too
      final prevLog = await repository.getPreviousExerciseLog(
        state.workoutType.name,
        alternativeId,
      );

      logs[originalId] = log.copyWith(
        performedExerciseId: alternativeId,
        weightKg: prevLog?.weightKg,
        isPerformed: false,
      );
      emit(state.copyWith(exerciseLogs: logs));
    }
  }

  Future<void> saveWorkout({bool forceSave = false}) async {
    if (state.exerciseLogs.isEmpty && state.workoutType != WorkoutType.rest) return;

    // Check for unconfirmed exercises
    final unconfirmedCount = state.exerciseLogs.values
        .where((log) => !log.isPerformed)
        .length;

    if (unconfirmedCount > 0 && !forceSave) {
      // This should be handled by the UI showing a dialog
      emit(state.copyWith(
        status: WorkoutStatus.failure,
        errorMessage: 'REVIEW_REQUIRED:$unconfirmedCount',
      ));
      return;
    }

    emit(state.copyWith(status: WorkoutStatus.saving));

    try {
      final session = WorkoutSession(
        dateKey: state.dateKey,
        workoutType: state.workoutType,
        exerciseLogs: state.exerciseLogs,
        displayUnit: state.displayUnit,
      );

      await repository.saveSession(session);
      emit(state.copyWith(status: WorkoutStatus.saved));
    } catch (e) {
      emit(state.copyWith(
        status: WorkoutStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void setPreferredUnit(WeightUnit unit) async {
    await repository.setPreferredUnit(unit);
    emit(state.copyWith(displayUnit: unit));
  }
}

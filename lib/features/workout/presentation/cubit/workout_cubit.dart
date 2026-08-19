import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_type.dart';
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
        emit(
          state.copyWith(
            status: WorkoutStatus.success,
            dateKey: dateKey,
            workoutType: session.workoutType,
            exerciseLogs: session.exerciseLogs,
            displayUnit: session.displayUnit,
            isEditMode: true,
          ),
        );
      } else {
        // No session found, initialize draft from catalog and prefill
        final workoutDef = WorkoutCatalog.getWorkoutForDate(date);
        final Map<String, ExerciseLog> logs = {};
        final Map<String, Map<String, ExerciseLog>> altDrafts = {};

        if (workoutDef != null) {
          for (final slot in workoutDef.exercises) {
            final log = await _createInitialLog(
              workoutType.name,
              slot.exerciseId,
              slot.prescribedSets,
            );
            logs[slot.exerciseId] = log;
            altDrafts[slot.exerciseId] = {slot.exerciseId: log};
          }
        }

        // Always add daily routine items to logs (Data-Driven)
        final dailyRoutine = WorkoutCatalog.getDailyRoutine();
        for (final slot in dailyRoutine.exercises) {
          if (!logs.containsKey(slot.exerciseId)) {
            final log = await _createInitialLog(
              'daily_routine',
              slot.exerciseId,
              slot.prescribedSets,
            );
            logs[slot.exerciseId] = log;
            altDrafts[slot.exerciseId] = {slot.exerciseId: log};
          }
        }

        emit(
          state.copyWith(
            status: WorkoutStatus.success,
            dateKey: dateKey,
            workoutType: workoutType,
            exerciseLogs: logs,
            alternativeDrafts: altDrafts,
            displayUnit: preferredUnit,
            isEditMode: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<ExerciseLog> _createInitialLog(
    String workoutTypeName,
    String exerciseId,
    int prescribedSets,
  ) async {
    final prevLog = await repository.getPreviousExerciseLog(
      workoutTypeName,
      exerciseId,
    );

    final List<ExerciseSetLog> sets = [];
    for (int i = 0; i < prescribedSets; i++) {
      double? weightKg;
      int? actualReps;
      if (prevLog != null && prevLog.sets.length > i) {
        weightKg = prevLog.sets[i].weightKg;
        actualReps = prevLog.sets[i].actualReps;
      }
      // Note: Legacy prefill (if prevLog.sets is empty but prevLog.weightKg exists)
      // is handled in the UI/Cubit action if needed.

      sets.add(
        ExerciseSetLog(
          weightKg: weightKg,
          actualReps: actualReps,
          isPerformed: false,
        ),
      );
    }

    return ExerciseLog(
      plannedExerciseId: exerciseId,
      performedExerciseId: exerciseId,
      sets: sets,
      weightKg: prevLog?.weightKg, // For legacy reference
      isPerformed: false,
      timestamp: DateTime.now(),
      displayUnit: prevLog?.displayUnit ?? state.displayUnit,
    );
  }

  void updateExerciseUnit(String plannedId, WeightUnit unit) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[plannedId];

    if (log != null) {
      final updatedLog = log.copyWith(displayUnit: unit);
      logs[plannedId] = updatedLog;

      final altDrafts = _updateAltDraft(plannedId, updatedLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
    }
  }

  void updateSetWeight(
    String plannedId,
    int setIndex,
    double? weight,
    WeightUnit unit,
  ) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[plannedId];

    if (log != null && log.sets.length > setIndex) {
      final weightKg = weight != null
          ? WeightConverter.convert(weight, unit, WeightUnit.kg)
          : null;

      final updatedSets = List<ExerciseSetLog>.from(log.sets);
      updatedSets[setIndex] = updatedSets[setIndex].copyWith(
        weightKg: weightKg,
        isPerformed: weight != null, // Auto-mark as performed
      );

      final updatedLog = log.copyWith(
        sets: updatedSets,
        timestamp: DateTime.now(),
      );

      logs[plannedId] = updatedLog;

      // Also update alternative drafts
      final altDrafts = _updateAltDraft(plannedId, updatedLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
    }
  }

  void updateSetReps(String plannedId, int setIndex, int? reps) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[plannedId];

    if (log != null && log.sets.length > setIndex) {
      final updatedSets = List<ExerciseSetLog>.from(log.sets);
      updatedSets[setIndex] = updatedSets[setIndex].copyWith(
        actualReps: reps,
        isPerformed: reps != null, // Auto-mark as performed
      );

      final updatedLog = log.copyWith(
        sets: updatedSets,
        timestamp: DateTime.now(),
      );

      logs[plannedId] = updatedLog;

      final altDrafts = _updateAltDraft(plannedId, updatedLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
    }
  }

  void toggleSetPerformed(String plannedId, int setIndex) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[plannedId];

    if (log != null && log.sets.length > setIndex) {
      final updatedSets = List<ExerciseSetLog>.from(log.sets);
      updatedSets[setIndex] = updatedSets[setIndex].copyWith(
        isPerformed: !updatedSets[setIndex].isPerformed,
      );

      final updatedLog = log.copyWith(
        sets: updatedSets,
        timestamp: DateTime.now(),
      );

      logs[plannedId] = updatedLog;

      final altDrafts = _updateAltDraft(plannedId, updatedLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
    }
  }

  Map<String, Map<String, ExerciseLog>> _updateAltDraft(
    String plannedId,
    ExerciseLog updatedLog,
  ) {
    final altDrafts = state.alternativeDrafts.map(
      (k, v) => MapEntry(k, Map<String, ExerciseLog>.from(v)),
    );
    final plannedDrafts = Map<String, ExerciseLog>.from(
      altDrafts[plannedId] ?? {},
    );
    plannedDrafts[updatedLog.performedExerciseId] = updatedLog;

    final updatedAltDrafts = Map<String, Map<String, ExerciseLog>>.from(
      altDrafts,
    );
    updatedAltDrafts[plannedId] = plannedDrafts;

    return updatedAltDrafts;
  }

  void useLegacyWeightForAllSets(String plannedId) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[plannedId];

    if (log != null && log.weightKg != null) {
      final updatedSets = log.sets
          .map((s) => s.copyWith(weightKg: log.weightKg, isPerformed: true))
          .toList();

      final updatedLog = log.copyWith(
        sets: updatedSets,
        timestamp: DateTime.now(),
      );

      logs[plannedId] = updatedLog;
      final altDrafts = _updateAltDraft(plannedId, updatedLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
    }
  }

  void selectAlternative(String plannedId, String alternativeId) async {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final currentLog = logs[plannedId];

    if (currentLog == null) return;

    // Check if we already have a draft for this alternative
    final plannedDrafts =
        state.alternativeDrafts[plannedId] ?? <String, ExerciseLog>{};

    if (plannedDrafts.containsKey(alternativeId)) {
      logs[plannedId] = plannedDrafts[alternativeId]!;
      emit(state.copyWith(exerciseLogs: logs));
    } else {
      // Create new draft for this alternative
      // Wait, we need to know how many sets for this slot.
      // We can get it from the currentLog since it was initialized with correct sets.
      final prescribedSets = currentLog.sets.length;

      final newLog = await _createInitialLog(
        state.workoutType == WorkoutType.rest
            ? 'daily_routine'
            : state.workoutType.name,
        alternativeId,
        prescribedSets,
      );

      // Important: Preserve the plannedExerciseId
      final alternativeLog = newLog.copyWith(
        plannedExerciseId: plannedId,
        performedExerciseId: alternativeId,
      );

      logs[plannedId] = alternativeLog;

      final altDrafts = _updateAltDraft(plannedId, alternativeLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
    }
  }

  void updatePhoto(String plannedId, String? imagePath) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[plannedId];

    if (log != null) {
      final updatedLog = log.copyWith(imagePath: imagePath);
      logs[plannedId] = updatedLog;

      final altDrafts = _updateAltDraft(plannedId, updatedLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
    }
  }

  Future<void> saveWorkout({bool forceSave = false}) async {
    if (state.exerciseLogs.isEmpty && state.workoutType != WorkoutType.rest) {
      return;
    }

    // An exercise is considered performed if at least one of its sets is performed.
    final List<ExerciseLog> performedLogs = [];
    final List<ExerciseLog> unperformedLogs = [];

    for (final log in state.exerciseLogs.values) {
      if (log.sets.any((s) => s.isPerformed)) {
        performedLogs.add(log);
      } else {
        unperformedLogs.add(log);
      }
    }

    if (unperformedLogs.isNotEmpty && !forceSave) {
      emit(
        state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: 'REVIEW_REQUIRED:${unperformedLogs.length}',
        ),
      );
      return;
    }

    emit(state.copyWith(status: WorkoutStatus.saving));

    try {
      // Persistence only keeps the currently selected performed exercises
      final session = WorkoutSession(
        dateKey: state.dateKey,
        workoutType: state.workoutType,
        exerciseLogs: state.exerciseLogs,
        displayUnit: state.displayUnit,
      );

      await repository.saveSession(session);
      emit(state.copyWith(status: WorkoutStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setPreferredUnit(WeightUnit unit) async {
    await repository.setPreferredUnit(unit);

    final logs = state.exerciseLogs.map(
      (k, v) => MapEntry(k, v.copyWith(displayUnit: unit)),
    );

    // Also update all drafts to keep them consistent with the new preference
    final altDrafts = state.alternativeDrafts.map(
      (k, v) => MapEntry(
        k,
        v.map((pk, pv) => MapEntry(pk, pv.copyWith(displayUnit: unit))),
      ),
    );

    emit(
      state.copyWith(
        displayUnit: unit,
        exerciseLogs: logs,
        alternativeDrafts: altDrafts,
      ),
    );
  }

  void navigateWeek(int weeks) {
    final nextDate = state.selectedDate.add(Duration(days: 7 * weeks));
    loadDate(nextDate);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/rest_time_parser.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';
import '../../domain/entities/workout_definition.dart';
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
    final preferredUnit = await repository.getPreferredUnit();

    try {
      final session = await repository.getSessionForDate(dateKey);

      if (session != null) {
        emit(
          state.copyWith(
            status: WorkoutStatus.success,
            dateKey: dateKey,
            selectedDate: date,
            workoutType: session.workoutType,
            exerciseLogs: session.exerciseLogs,
            displayUnit: session.displayUnit,
            isEditMode: true,
          ),
        );
      } else {
        // No session found, determine workout type from sequence
        // Important: Filter history to only include sessions BEFORE the selected date
        final history = await repository.getHistory();
        final pastTypes = history
            .where((s) => s.dateKey.compareTo(dateKey) < 0)
            .toList()
          ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

        final workoutTypes = pastTypes.map((s) => s.workoutType).toList();
        
        WorkoutType suggestedType;
        if (workoutTypes.isEmpty) {
          // Fallback to calendar if no history exists yet
          suggestedType = WorkoutDateUtils.getWorkoutTypeForDay(date);
        } else {
          // Calculate the number of days passed since the last session
          final lastSessionDate = WorkoutDateUtils.parseDateKey(pastTypes.first.dateKey);
          final daysPassed = date.difference(lastSessionDate).inDays;

          // Advance the sequence by 'daysPassed' steps
          suggestedType = workoutTypes.first;
          for (int i = 0; i < daysPassed; i++) {
            suggestedType = WorkoutCatalog.getNextWorkoutType([suggestedType, ...workoutTypes.skip(1)]);
            // Update history list for the next iteration step to handle Rest days correctly
            workoutTypes.insert(0, suggestedType);
          }
        }

        final logs = await _initializeLogsForType(suggestedType);

        emit(
          state.copyWith(
            status: WorkoutStatus.success,
            dateKey: dateKey,
            selectedDate: date,
            workoutType: suggestedType,
            exerciseLogs: logs,
            alternativeDrafts: {
              for (var log in logs.values)
                log.plannedExerciseId: {log.performedExerciseId: log},
            },
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
        isPerformed: updatedSets[setIndex].isPerformed, // Preserves manual toggle state
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
        isPerformed: updatedSets[setIndex].isPerformed, // Preserves manual toggle state
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
      final wasPerformed = log.sets[setIndex].isPerformed;
      final updatedSets = List<ExerciseSetLog>.from(log.sets);
      final newPerformed = !wasPerformed;

      updatedSets[setIndex] = updatedSets[setIndex].copyWith(
        isPerformed: newPerformed,
      );

      final updatedLog = log.copyWith(
        sets: updatedSets,
        timestamp: DateTime.now(),
      );

      logs[plannedId] = updatedLog;

      final altDrafts = _updateAltDraft(plannedId, updatedLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));

      if (newPerformed) {
        final exerciseDef = WorkoutCatalog.getExerciseById(log.performedExerciseId);
        final workoutDef = WorkoutCatalog.getWorkoutByType(state.workoutType);
        ExerciseSlot? foundSlot;
        if (workoutDef != null) {
          for (final slot in workoutDef.exercises) {
            if (slot.exerciseId == log.plannedExerciseId) {
              foundSlot = slot;
              break;
            }
          }
        }
        if (foundSlot == null) {
          for (final slot in WorkoutCatalog.getDailyRoutine().exercises) {
            if (slot.exerciseId == log.plannedExerciseId) {
              foundSlot = slot;
              break;
            }
          }
        }

        final restSecs = RestTimeParser.parseInSeconds(foundSlot?.prescribedRest);
        startRestTimer(restSecs, exerciseDef.name);
      }
    }
  }

  void startRestTimer(int durationSeconds, String exerciseName) {
    emit(
      state.copyWith(
        isRestTimerActive: true,
        restTimerSeconds: durationSeconds,
        restTimerTargetSeconds: durationSeconds,
        restTimerExerciseName: exerciseName,
      ),
    );
  }

  void tickRestTimer() {
    if (!state.isRestTimerActive) return;
    if (state.restTimerSeconds <= 1) {
      emit(
        state.copyWith(
          isRestTimerActive: false,
          restTimerSeconds: 0,
        ),
      );
    } else {
      emit(
        state.copyWith(
          restTimerSeconds: state.restTimerSeconds - 1,
        ),
      );
    }
  }

  void addRestTimerSeconds(int seconds) {
    if (!state.isRestTimerActive) return;
    emit(
      state.copyWith(
        restTimerSeconds: state.restTimerSeconds + seconds,
        restTimerTargetSeconds: state.restTimerTargetSeconds + seconds,
      ),
    );
  }

  void skipRestTimer() {
    emit(
      state.copyWith(
        isRestTimerActive: false,
        restTimerSeconds: 0,
      ),
    );
  }

  Future<void> copyPreviousSession(String plannedId) async {
    final log = state.exerciseLogs[plannedId];
    if (log == null) return;

    final prevLog = await repository.getPreviousExerciseLog(
      state.workoutType == WorkoutType.rest
          ? 'daily_routine'
          : state.workoutType.name,
      log.performedExerciseId,
    );

    if (prevLog == null || prevLog.sets.isEmpty) return;

    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final updatedSets = <ExerciseSetLog>[];

    for (int i = 0; i < log.sets.length; i++) {
      if (i < prevLog.sets.length) {
        updatedSets.add(
          log.sets[i].copyWith(
            weightKg: prevLog.sets[i].weightKg,
            actualReps: prevLog.sets[i].actualReps,
          ),
        );
      } else {
        final lastPrevSet = prevLog.sets.last;
        updatedSets.add(
          log.sets[i].copyWith(
            weightKg: lastPrevSet.weightKg,
            actualReps: lastPrevSet.actualReps,
          ),
        );
      }
    }

    final updatedLog = log.copyWith(
      sets: updatedSets,
      timestamp: DateTime.now(),
    );

    logs[plannedId] = updatedLog;
    final altDrafts = _updateAltDraft(plannedId, updatedLog);

    emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
  }

  void addSet(String plannedId) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[plannedId];

    if (log != null) {
      final updatedSets = List<ExerciseSetLog>.from(log.sets);
      final lastSet = updatedSets.isNotEmpty ? updatedSets.last : null;

      updatedSets.add(
        ExerciseSetLog(
          weightKg: lastSet?.weightKg,
          actualReps: lastSet?.actualReps,
          isPerformed: false,
        ),
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

  void removeSet(String plannedId, int setIndex) {
    final logs = Map<String, ExerciseLog>.from(state.exerciseLogs);
    final log = logs[plannedId];

    if (log != null && log.sets.length > 1 && setIndex < log.sets.length) {
      final updatedSets = List<ExerciseSetLog>.from(log.sets);
      updatedSets.removeAt(setIndex);

      final updatedLog = log.copyWith(
        sets: updatedSets,
        timestamp: DateTime.now(),
      );

      logs[plannedId] = updatedLog;
      final altDrafts = _updateAltDraft(plannedId, updatedLog);

      emit(state.copyWith(exerciseLogs: logs, alternativeDrafts: altDrafts));
    }
  }

  void stepWeight(String plannedId, int setIndex, double deltaAmount) {
    final log = state.exerciseLogs[plannedId];
    if (log != null && log.sets.length > setIndex) {
      final currentKg = log.sets[setIndex].weightKg ?? 0.0;
      final currentUnitValue = WeightConverter.convert(
        currentKg,
        WeightUnit.kg,
        log.displayUnit,
      );
      final newUnitValue = (currentUnitValue + deltaAmount).clamp(0.0, 999.0);
      updateSetWeight(plannedId, setIndex, newUnitValue, log.displayUnit);
    }
  }

  void stepReps(String plannedId, int setIndex, int deltaAmount) {
    final log = state.exerciseLogs[plannedId];
    if (log != null && log.sets.length > setIndex) {
      final currentReps = log.sets[setIndex].actualReps ?? 0;
      final newReps = (currentReps + deltaAmount).clamp(0, 999);
      updateSetReps(plannedId, setIndex, newReps);
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

  Future<void> saveWorkout({
    bool forceSave = false,
    bool isCompletion = true,
  }) async {
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

    if (isCompletion) {
      emit(state.copyWith(status: WorkoutStatus.saving));
    }

    try {
      // Persistence only keeps the currently selected performed exercises
      final session = WorkoutSession(
        dateKey: state.dateKey,
        workoutType: state.workoutType,
        exerciseLogs: state.exerciseLogs,
        displayUnit: state.displayUnit,
      );

      await repository.saveSession(session);

      if (isCompletion) {
        emit(state.copyWith(status: WorkoutStatus.saved));
      } else {
        emit(state.copyWith(status: WorkoutStatus.success));
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

  Future<void> changeWorkoutType(WorkoutType type) async {
    if (state.status == WorkoutStatus.loading || state.status == WorkoutStatus.saving) return;

    emit(state.copyWith(status: WorkoutStatus.loading));

    try {
      final logs = await _initializeLogsForType(type);

      emit(
        state.copyWith(
          status: WorkoutStatus.success,
          workoutType: type,
          exerciseLogs: logs,
          alternativeDrafts: {
            for (var log in logs.values) log.plannedExerciseId: {log.performedExerciseId: log},
          },
          // We keep the dateKey and isEditMode as is. 
          // If it was an existing session, changing the type will effectively 
          // allow the user to overwrite it with new exercises.
        ),
      );

      // Persist the selection immediately so it sticks when navigating
      await saveWorkout(forceSave: true, isCompletion: false);
    } catch (e) {
      emit(state.copyWith(status: WorkoutStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> clearWorkout() async {
    emit(state.copyWith(status: WorkoutStatus.saving));
    try {
      await repository.deleteSession(state.dateKey);
      await loadDate(state.selectedDate); // Re-suggest based on sequence
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<Map<String, ExerciseLog>> _initializeLogsForType(WorkoutType type) async {
    final workoutDef = WorkoutCatalog.getWorkoutByType(type);
    final Map<String, ExerciseLog> logs = {};

    if (workoutDef != null) {
      for (final slot in workoutDef.exercises) {
        final log = await _createInitialLog(
          type.name,
          slot.exerciseId,
          slot.prescribedSets,
        );
        logs[slot.exerciseId] = log;
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
      }
    }
    return logs;
  }
}

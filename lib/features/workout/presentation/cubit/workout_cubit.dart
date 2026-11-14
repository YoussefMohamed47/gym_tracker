import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/api_result.dart';
import '../../../../core/utils/rest_time_parser.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';
import '../../domain/entities/workout_definition.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_type.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/usecases/check_pr_usecase.dart';
import '../../domain/usecases/get_previous_exercise_log.dart';
import '../../domain/usecases/save_workout_session.dart';
import '../../utils/date_utils.dart';
import 'workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutRepository repository;
  final GetPreviousExerciseLog getPreviousExerciseLog;
  final SaveWorkoutSession saveWorkoutSession;
  final CheckPRUseCase? checkPRUseCase;

  /// How long after the last edit the open day saves itself; null turns
  /// auto-save off (tests).
  final Duration? autoSaveDelay;

  Timer? _autoSaveTimer;

  WorkoutCubit({
    required this.repository,
    required this.getPreviousExerciseLog,
    required this.saveWorkoutSession,
    this.checkPRUseCase,
    this.autoSaveDelay = const Duration(milliseconds: 800),
  }) : super(WorkoutState.initial());

  /// A day is worth keeping once a set is ticked, or once it was saved
  /// before. Untouched days are never written, so they don't count as
  /// trained in the rotation.
  static bool _worthSaving(WorkoutState s) =>
      s.isEditMode ||
      s.exerciseLogs.values.any((log) => log.sets.any((x) => x.isPerformed));

  void _scheduleAutoSave() {
    final delay = autoSaveDelay;
    if (delay == null) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(delay, _autoSave);
  }

  /// Saves the open day without changing the screen's status.
  Future<void> _autoSave() async {
    _autoSaveTimer = null;
    final snapshot = state;
    if (isClosed ||
        snapshot.dateKey.isEmpty ||
        snapshot.status == WorkoutStatus.loading ||
        snapshot.status == WorkoutStatus.saving ||
        !_worthSaving(snapshot)) {
      return;
    }
    try {
      // Through the use case, which also removes photos you replaced.
      await saveWorkoutSession(
        WorkoutSession(
          dateKey: snapshot.dateKey,
          workoutType: snapshot.workoutType,
          exerciseLogs: snapshot.exerciseLogs,
          displayUnit: snapshot.displayUnit,
        ),
      );
      // The day now exists in storage: keep saving even if every set is
      // unticked later.
      if (!isClosed && state.dateKey == snapshot.dateKey && !state.isEditMode) {
        emit(state.copyWith(isEditMode: true));
      }
    } catch (e) {
      debugPrint('WorkoutCubit: auto-save failed: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: WorkoutStatus.failure,
            errorMessage: "Couldn't save your workout. Try Finish again.",
          ),
        );
      }
    }
  }

  /// Writes an edit still waiting for its auto-save right away.
  Future<void> _flushPendingAutoSave() async {
    if (!(_autoSaveTimer?.isActive ?? false)) return;
    _autoSaveTimer!.cancel();
    await _autoSave();
  }

  @override
  Future<void> close() async {
    // Don't lose the last edit when the screen goes away.
    await _flushPendingAutoSave();
    return super.close();
  }

  /// The last time each exercise was done, before [beforeDateKey] (today when
  /// no day is open yet). A failed lookup just means nothing to show.
  Future<Map<String, PreviousExerciseLog>> _lastPerformed(
    List<String> exerciseIds,
    String beforeDateKey,
  ) async {
    final result = await getPreviousExerciseLog(
      exerciseIds,
      beforeDateKey: beforeDateKey.isEmpty
          ? WorkoutDateUtils.formatDateKey(DateTime.now())
          : beforeDateKey,
    );
    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case ApiFailure(:final failure):
        debugPrint('WorkoutCubit: last-time lookup failed: ${failure.message}');
        return const {};
    }
  }

  /// Which exercise is performed in each slot on which date; when it changes
  /// (new day, new workout type, or a swap) "last time" is looked up again.
  static String _previousLookupKey(WorkoutState s) =>
      '${s.dateKey}#${s.exerciseLogs.entries.map((e) => '${e.key}:${e.value.performedExerciseId}').join(',')}';

  @override
  void onChange(Change<WorkoutState> change) {
    super.onChange(change);
    final next = change.nextState;
    if (next.dateKey.isEmpty || next.exerciseLogs.isEmpty) return;
    // An edit on the same day (not a day loading): save it shortly.
    if (!identical(change.currentState.exerciseLogs, next.exerciseLogs) &&
        change.currentState.dateKey == next.dateKey &&
        _worthSaving(next)) {
      _scheduleAutoSave();
    }
    if (_previousLookupKey(change.currentState) != _previousLookupKey(next)) {
      _loadPreviousLogs(next);
    }
  }

  Future<void> _loadPreviousLogs(WorkoutState forState) async {
    final byExercise = await _lastPerformed([
      for (final log in forState.exerciseLogs.values) log.performedExerciseId,
    ], forState.dateKey);
    final found = <String, PreviousExerciseLog>{
      for (final entry in forState.exerciseLogs.entries)
        entry.key: ?byExercise[entry.value.performedExerciseId],
    };
    // Ignore the result if the user moved to another day meanwhile.
    if (isClosed || _previousLookupKey(state) != _previousLookupKey(forState)) {
      return;
    }
    emit(state.copyWith(previousLogs: found));
  }

  /// The calendar day on which [ensureToday] last opened today's workout.
  String? _openedOnDayKey;

  /// Opens today's workout the first time, and again once the calendar day
  /// has changed (e.g. the app stayed in memory since the last training).
  /// On the same day it keeps whatever date you are looking at.
  ///
  /// Sets ticked done on the open day are saved before switching, so a
  /// workout that runs past midnight is not lost.
  Future<void> ensureToday(DateTime now) async {
    final todayKey = WorkoutDateUtils.formatDateKey(now);
    if (state.dateKey.isNotEmpty && _openedOnDayKey == todayKey) return;
    if (state.status == WorkoutStatus.loading ||
        state.status == WorkoutStatus.saving) {
      return;
    }
    _openedOnDayKey = todayKey;

    final hasDoneSets = state.exerciseLogs.values.any(
      (log) => log.sets.any((s) => s.isPerformed),
    );
    if (state.dateKey.isNotEmpty && hasDoneSets) {
      await saveWorkout(forceSave: true, isCompletion: false);
      if (state.status == WorkoutStatus.failure) {
        // Keep the unsaved day on screen; try again on the next return.
        _openedOnDayKey = null;
        return;
      }
    }
    await loadDate(now);
  }

  Future<void> loadDate(DateTime date) async {
    // Save the day being left first, so an edit made just before switching
    // isn't lost.
    await _flushPendingAutoSave();
    emit(state.copyWith(status: WorkoutStatus.loading, selectedDate: date));

    final dateKey = WorkoutDateUtils.formatDateKey(date);
    final preferredUnit = await repository.getPreferredUnit();

    try {
      final session = await repository.getSessionForDate(dateKey);

      if (session != null) {
        var logs = session.exerciseLogs;
        if (session.workoutType.isUpperBody) {
          final missing = WorkoutCatalog.getUpperBodyWarmup().exercises
              .where((slot) => !logs.containsKey(slot.exerciseId))
              .toList();
          if (missing.isNotEmpty) {
            logs = {
              ...logs,
              ...await _createInitialLogs(missing, beforeDateKey: dateKey),
            };
          }
        }

        emit(
          state.copyWith(
            status: WorkoutStatus.success,
            dateKey: dateKey,
            selectedDate: date,
            workoutType: session.workoutType,
            mainExerciseIds: _mainExerciseIds(session.workoutType),
            exerciseLogs: logs,
            displayUnit: session.displayUnit,
            isEditMode: true,
          ),
        );
      } else {
        // No session found, determine workout type from sequence
        // Important: Filter history to only include sessions BEFORE the selected date
        final history = await repository.getHistory();
        final pastTypes =
            history.where((s) => s.dateKey.compareTo(dateKey) < 0).toList()
              ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

        final workoutTypes = pastTypes.map((s) => s.workoutType).toList();

        WorkoutType suggestedType;
        if (workoutTypes.isEmpty) {
          // Fallback to calendar if no history exists yet
          // No history yet: start the 8-day rotation at day 1.
          suggestedType = WorkoutCatalog.trainingSequence.first;
        } else {
          // Calculate the number of days passed since the last session
          final lastSessionDate = WorkoutDateUtils.parseDateKey(
            pastTypes.first.dateKey,
          );
          final daysPassed = date.difference(lastSessionDate).inDays;

          // Advance the sequence by 'daysPassed' steps
          suggestedType = workoutTypes.first;
          for (int i = 0; i < daysPassed; i++) {
            suggestedType = WorkoutCatalog.getNextWorkoutType([
              suggestedType,
              ...workoutTypes.skip(1),
            ]);
            // Update history list for the next iteration step to handle Rest days correctly
            workoutTypes.insert(0, suggestedType);
          }
        }

        final logs = await _initializeLogsForType(
          suggestedType,
          beforeDateKey: dateKey,
        );

        emit(
          state.copyWith(
            status: WorkoutStatus.success,
            dateKey: dateKey,
            selectedDate: date,
            workoutType: suggestedType,
            mainExerciseIds: _mainExerciseIds(suggestedType),
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

  /// Fresh logs for [slots], keyed by exercise ID, each prefilled with the
  /// weight and reps of the last time it was done on any training day before
  /// [beforeDateKey]. History is read once for all of them.
  Future<Map<String, ExerciseLog>> _createInitialLogs(
    List<ExerciseSlot> slots, {
    required String beforeDateKey,
  }) async {
    final previous = await _lastPerformed([
      for (final slot in slots) slot.exerciseId,
    ], beforeDateKey);
    return {
      for (final slot in slots)
        slot.exerciseId: _buildInitialLog(
          slot.exerciseId,
          slot.prescribedSets,
          previous[slot.exerciseId]?.log,
        ),
    };
  }

  ExerciseLog _buildInitialLog(
    String exerciseId,
    int prescribedSets,
    ExerciseLog? prevLog,
  ) {
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
        isPerformed:
            updatedSets[setIndex].isPerformed, // Preserves manual toggle state
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
        isPerformed:
            updatedSets[setIndex].isPerformed, // Preserves manual toggle state
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

  Future<void> toggleSetPerformed(String plannedId, int setIndex) async {
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

      if (newPerformed && checkPRUseCase != null) {
        // Check for PR
        final currentSet = updatedSets[setIndex];
        if (currentSet.weightKg != null || currentSet.actualReps != null) {
          final isPR = await checkPRUseCase!(
            exerciseId: log.performedExerciseId,
            weightKg: currentSet.weightKg,
            actualReps: currentSet.actualReps,
            currentDateKey: state.dateKey,
          );

          if (isPR) {
            emit(state.copyWith(prAchievedForPlannedId: plannedId));
            // Clear PR flag after a short delay so it can be re-triggered for other sets
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!isClosed) emit(state.copyWith(clearPR: true));
            });
          }
        }

        final exerciseDef = WorkoutCatalog.getExerciseById(
          log.performedExerciseId,
        );
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

        final restSecs = RestTimeParser.parseInSeconds(
          foundSlot?.prescribedRest,
        );
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
      emit(state.copyWith(isRestTimerActive: false, restTimerSeconds: 0));
    } else {
      emit(state.copyWith(restTimerSeconds: state.restTimerSeconds - 1));
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
    emit(state.copyWith(isRestTimerActive: false, restTimerSeconds: 0));
  }

  Future<void> copyPreviousSession(String plannedId) async {
    final log = state.exerciseLogs[plannedId];
    if (log == null) return;

    final prevLog = (await _lastPerformed([
      log.performedExerciseId,
    ], state.dateKey))[log.performedExerciseId]?.log;

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
      final currentReps = log.sets[setIndex].actualReps;
      final int baseReps = currentReps ?? (deltaAmount > 0 ? 10 : 0);
      final newReps =
          (currentReps != null ? currentReps + deltaAmount : baseReps).clamp(
            0,
            999,
          );
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

      final previous = await _lastPerformed([alternativeId], state.dateKey);
      final newLog = _buildInitialLog(
        alternativeId,
        prescribedSets,
        previous[alternativeId]?.log,
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

  void clearError() {
    emit(
      state.copyWith(status: WorkoutStatus.success, clearErrorMessage: true),
    );
  }

  void resetStatus() {
    emit(
      state.copyWith(status: WorkoutStatus.success, clearErrorMessage: true),
    );
  }

  Future<void> saveWorkout({
    bool forceSave = false,
    bool isCompletion = true,
  }) async {
    if (state.exerciseLogs.isEmpty && state.workoutType != WorkoutType.rest) {
      return;
    }
    // This save covers any pending auto-save.
    _autoSaveTimer?.cancel();

    // An exercise is done once one of its sets is. Only the main lifts are
    // checked (the routine on a rest day), the same ones the dock counts.
    final notDone = state.progress.exercisesNotDone;

    if (notDone > 0 && !forceSave) {
      emit(
        state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: 'REVIEW_REQUIRED:$notDone',
        ),
      );
      return;
    }

    if (isCompletion) {
      emit(
        state.copyWith(status: WorkoutStatus.saving, clearErrorMessage: true),
      );
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
        emit(
          state.copyWith(status: WorkoutStatus.saved, clearErrorMessage: true),
        );
      } else {
        emit(
          state.copyWith(
            status: WorkoutStatus.success,
            clearErrorMessage: true,
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
    if (state.status == WorkoutStatus.loading ||
        state.status == WorkoutStatus.saving) {
      return;
    }

    emit(state.copyWith(status: WorkoutStatus.loading));

    try {
      final logs = await _initializeLogsForType(
        type,
        beforeDateKey: state.dateKey,
      );

      emit(
        state.copyWith(
          status: WorkoutStatus.success,
          workoutType: type,
          mainExerciseIds: _mainExerciseIds(type),
          exerciseLogs: logs,
          alternativeDrafts: {
            for (var log in logs.values)
              log.plannedExerciseId: {log.performedExerciseId: log},
          },
          // We keep the dateKey and isEditMode as is.
          // If it was an existing session, changing the type will effectively
          // allow the user to overwrite it with new exercises.
        ),
      );

      // Persist the selection immediately so it sticks when navigating
      await saveWorkout(forceSave: true, isCompletion: false);
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkoutStatus.failure,
          errorMessage: e.toString(),
        ),
      );
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

  /// The day's planned lifts, without warm-up or routine; none on rest days.
  static List<String> _mainExerciseIds(WorkoutType type) => [
    ...?WorkoutCatalog.getWorkoutByType(
      type,
    )?.exercises.map((slot) => slot.exerciseId),
  ];

  Future<Map<String, ExerciseLog>> _initializeLogsForType(
    WorkoutType type, {
    required String beforeDateKey,
  }) async {
    final workoutDef = WorkoutCatalog.getWorkoutByType(type);
    // First slot per exercise wins: the day's own, then the upper-body
    // warm-up if applicable, then the daily routine (always included).
    final slots = <String, ExerciseSlot>{};
    for (final slot in [
      ...?workoutDef?.exercises,
      if (type.isUpperBody) ...WorkoutCatalog.getUpperBodyWarmup().exercises,
      ...WorkoutCatalog.getDailyRoutine().exercises,
    ]) {
      slots.putIfAbsent(slot.exerciseId, () => slot);
    }
    return _createInitialLogs(
      slots.values.toList(),
      beforeDateKey: beforeDateKey,
    );
  }
}

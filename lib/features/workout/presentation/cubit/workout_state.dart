import 'package:equatable/equatable.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/workout_type.dart';

enum WorkoutStatus { initial, loading, success, failure, saving, saved }

/// The most recent earlier session of an exercise, for the "Last time" panel.
class PreviousExerciseLog extends Equatable {
  final String dateKey;
  final ExerciseLog log;
  const PreviousExerciseLog({required this.dateKey, required this.log});

  @override
  List<Object?> get props => [dateKey, log];
}

class WorkoutState extends Equatable {
  final WorkoutStatus status;
  final DateTime selectedDate;
  final String dateKey;
  final WorkoutType workoutType;
  final Map<String, ExerciseLog> exerciseLogs;

  /// Stores in-session drafts for alternatives.
  /// Key: plannedExerciseId -> Map(performedExerciseId -> ExerciseLog)
  final Map<String, Map<String, ExerciseLog>> alternativeDrafts;

  final WeightUnit displayUnit;
  final bool isEditMode;
  final String? errorMessage;

  // Rest Timer State
  final bool isRestTimerActive;
  final int restTimerSeconds;
  final int restTimerTargetSeconds;
  final String restTimerExerciseName;

  // PR Gamification
  final String? prAchievedForPlannedId;

  /// Key: plannedExerciseId. Filled in after load, only from dates before
  /// [dateKey], so today's own sets never count as "last time".
  final Map<String, PreviousExerciseLog> previousLogs;

  const WorkoutState({
    required this.status,
    required this.selectedDate,
    required this.dateKey,
    required this.workoutType,
    required this.exerciseLogs,
    this.alternativeDrafts = const {},
    required this.displayUnit,
    this.isEditMode = false,
    this.errorMessage,
    this.isRestTimerActive = false,
    this.restTimerSeconds = 0,
    this.restTimerTargetSeconds = 0,
    this.restTimerExerciseName = '',
    this.prAchievedForPlannedId,
    this.previousLogs = const {},
  });

  factory WorkoutState.initial() {
    final now = DateTime.now();
    return WorkoutState(
      status: WorkoutStatus.initial,
      selectedDate: now,
      dateKey: '', // Will be set by cubit
      workoutType: WorkoutType.rest,
      exerciseLogs: const {},
      alternativeDrafts: const {},
      displayUnit: WeightUnit.kg,
      isRestTimerActive: false,
      restTimerSeconds: 0,
      restTimerTargetSeconds: 0,
      restTimerExerciseName: '',
    );
  }

  WorkoutState copyWith({
    WorkoutStatus? status,
    DateTime? selectedDate,
    String? dateKey,
    WorkoutType? workoutType,
    Map<String, ExerciseLog>? exerciseLogs,
    Map<String, Map<String, ExerciseLog>>? alternativeDrafts,
    WeightUnit? displayUnit,
    bool? isEditMode,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isRestTimerActive,
    int? restTimerSeconds,
    int? restTimerTargetSeconds,
    String? restTimerExerciseName,
    String? prAchievedForPlannedId,
    bool clearPR = false,
    Map<String, PreviousExerciseLog>? previousLogs,
  }) {
    return WorkoutState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      dateKey: dateKey ?? this.dateKey,
      workoutType: workoutType ?? this.workoutType,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      alternativeDrafts: alternativeDrafts ?? this.alternativeDrafts,
      displayUnit: displayUnit ?? this.displayUnit,
      isEditMode: isEditMode ?? this.isEditMode,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      isRestTimerActive: isRestTimerActive ?? this.isRestTimerActive,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      restTimerTargetSeconds:
          restTimerTargetSeconds ?? this.restTimerTargetSeconds,
      restTimerExerciseName:
          restTimerExerciseName ?? this.restTimerExerciseName,
      prAchievedForPlannedId: clearPR
          ? null
          : (prAchievedForPlannedId ?? this.prAchievedForPlannedId),
      previousLogs: previousLogs ?? this.previousLogs,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedDate,
    dateKey,
    workoutType,
    exerciseLogs,
    alternativeDrafts,
    displayUnit,
    isEditMode,
    errorMessage,
    isRestTimerActive,
    restTimerSeconds,
    restTimerTargetSeconds,
    restTimerExerciseName,
    prAchievedForPlannedId,
    previousLogs,
  ];
}

import 'package:equatable/equatable.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/workout_type.dart';

enum WorkoutStatus { initial, loading, success, failure, saving, saved }

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
      errorMessage: errorMessage ?? this.errorMessage,
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
  ];
}

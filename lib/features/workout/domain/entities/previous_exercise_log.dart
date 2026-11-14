import 'package:equatable/equatable.dart';
import 'exercise_log.dart';

/// The most recent earlier session of an exercise: shown as "Last time" and
/// used to prefill the next session's weight and reps.
class PreviousExerciseLog extends Equatable {
  final String dateKey;
  final ExerciseLog log;
  const PreviousExerciseLog({required this.dateKey, required this.log});

  @override
  List<Object?> get props => [dateKey, log];
}

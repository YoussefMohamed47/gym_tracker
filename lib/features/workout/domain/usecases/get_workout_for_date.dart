import 'package:intl/intl.dart';
import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class GetWorkoutForDate {
  final WorkoutRepository repository;

  GetWorkoutForDate(this.repository);

  Future<WorkoutSession?> call(DateTime date) async {
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);
    return await repository.getSessionForDate(dateKey);
  }
}

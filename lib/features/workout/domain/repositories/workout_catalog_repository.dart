import '../entities/catalog_day.dart';
import '../entities/catalog_exercise.dart';
import '../entities/workout_type.dart';

abstract class WorkoutCatalogRepository {
  List<CatalogDay> getEightDayRotation();
  CatalogDay getDay(int dayNumber);
  CatalogDay? getDayByWorkoutType(WorkoutType type);
  CatalogExercise? getExerciseById(String id);
  List<CatalogExercise> getAlternatives(String exerciseId);
}

import '../entities/catalog_day.dart';
import '../repositories/workout_catalog_repository.dart';

class GetWorkoutCatalog {
  final WorkoutCatalogRepository repository;

  const GetWorkoutCatalog(this.repository);

  List<CatalogDay> call() {
    return repository.getEightDayRotation();
  }

  CatalogDay getDay(int dayNumber) {
    return repository.getDay(dayNumber);
  }
}

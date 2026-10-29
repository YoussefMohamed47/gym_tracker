import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_workout_catalog.dart';
import 'workout_catalog_state.dart';

class WorkoutCatalogCubit extends Cubit<WorkoutCatalogState> {
  final GetWorkoutCatalog getWorkoutCatalog;

  WorkoutCatalogCubit({required this.getWorkoutCatalog})
      : super(const WorkoutCatalogInitial()) {
    loadCatalog();
  }

  void loadCatalog() {
    try {
      emit(const WorkoutCatalogLoading());
      final days = getWorkoutCatalog();
      emit(WorkoutCatalogLoaded(rotationDays: days, selectedDayNumber: 1));
    } catch (e) {
      emit(WorkoutCatalogError(e.toString()));
    }
  }

  void selectDay(int dayNumber) {
    if (state is WorkoutCatalogLoaded) {
      final current = state as WorkoutCatalogLoaded;
      emit(current.copyWith(selectedDayNumber: dayNumber));
    }
  }
}

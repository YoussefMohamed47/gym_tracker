import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/data/repositories/workout_catalog_repository_impl.dart';
import 'package:gym_tracker_report/features/workout/domain/usecases/get_workout_catalog.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_catalog_cubit.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_catalog_state.dart';

void main() {
  late WorkoutCatalogRepositoryImpl repository;
  late GetWorkoutCatalog getWorkoutCatalog;
  late WorkoutCatalogCubit cubit;

  setUp(() {
    repository = WorkoutCatalogRepositoryImpl();
    getWorkoutCatalog = GetWorkoutCatalog(repository);
    cubit = WorkoutCatalogCubit(getWorkoutCatalog: getWorkoutCatalog);
  });

  tearDown(() {
    cubit.close();
  });

  group('WorkoutCatalogCubit Tests', () {
    test('initial state loads 8-day rotation with day 1 selected', () {
      expect(cubit.state, isA<WorkoutCatalogLoaded>());
      final loaded = cubit.state as WorkoutCatalogLoaded;
      expect(loaded.rotationDays.length, 8);
      expect(loaded.selectedDayNumber, 1);
      expect(loaded.selectedDay.title, 'Chest & Back');
    });

    test('selectDay changes selected day number and selectedDay entity', () {
      cubit.selectDay(3);
      final loaded = cubit.state as WorkoutCatalogLoaded;
      expect(loaded.selectedDayNumber, 3);
      expect(loaded.selectedDay.title, 'Legs');
      expect(loaded.selectedDay.exercises.length, 7);
    });

    test('selectDay changes to rest day accurately', () {
      cubit.selectDay(4);
      final loaded = cubit.state as WorkoutCatalogLoaded;
      expect(loaded.selectedDayNumber, 4);
      expect(loaded.selectedDay.isRestDay, isTrue);
      expect(loaded.selectedDay.exercises, isEmpty);
    });
  });
}

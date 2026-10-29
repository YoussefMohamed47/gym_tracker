import 'package:equatable/equatable.dart';
import '../../domain/entities/catalog_day.dart';

sealed class WorkoutCatalogState extends Equatable {
  const WorkoutCatalogState();

  @override
  List<Object?> get props => [];
}

class WorkoutCatalogInitial extends WorkoutCatalogState {
  const WorkoutCatalogInitial();
}

class WorkoutCatalogLoading extends WorkoutCatalogState {
  const WorkoutCatalogLoading();
}

class WorkoutCatalogLoaded extends WorkoutCatalogState {
  final List<CatalogDay> rotationDays;
  final int selectedDayNumber;

  const WorkoutCatalogLoaded({
    required this.rotationDays,
    this.selectedDayNumber = 1,
  });

  CatalogDay get selectedDay => rotationDays.firstWhere(
        (d) => d.dayNumber == selectedDayNumber,
        orElse: () => rotationDays.first,
      );

  WorkoutCatalogLoaded copyWith({
    List<CatalogDay>? rotationDays,
    int? selectedDayNumber,
  }) {
    return WorkoutCatalogLoaded(
      rotationDays: rotationDays ?? this.rotationDays,
      selectedDayNumber: selectedDayNumber ?? this.selectedDayNumber,
    );
  }

  @override
  List<Object?> get props => [rotationDays, selectedDayNumber];
}

class WorkoutCatalogError extends WorkoutCatalogState {
  final String message;

  const WorkoutCatalogError(this.message);

  @override
  List<Object?> get props => [message];
}

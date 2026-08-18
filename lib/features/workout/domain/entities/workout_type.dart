enum WorkoutType {
  pull,
  legs,
  rest,
  upper,
  lower,
  push;

  String get displayName {
    switch (this) {
      case WorkoutType.pull:
        return 'Pull';
      case WorkoutType.legs:
        return 'Legs';
      case WorkoutType.rest:
        return 'Rest Day';
      case WorkoutType.upper:
        return 'Upper Body';
      case WorkoutType.lower:
        return 'Lower Body';
      case WorkoutType.push:
        return 'Push';
    }
  }
}

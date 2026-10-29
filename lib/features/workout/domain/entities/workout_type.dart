enum WorkoutType {
  // 8-Day Rotation Types
  chestAndBack,
  shoulderAndArms,
  legs,
  rest,
  fullBody,
  upperAndCalves,

  // Legacy Types (kept for backward compatibility with historical records)
  pull,
  upper,
  lower,
  push;

  String get displayName {
    switch (this) {
      case WorkoutType.chestAndBack:
        return 'Chest & Back';
      case WorkoutType.shoulderAndArms:
        return 'Shoulder & Arms';
      case WorkoutType.legs:
        return 'Legs';
      case WorkoutType.rest:
        return 'Rest Day';
      case WorkoutType.fullBody:
        return 'Full Body';
      case WorkoutType.upperAndCalves:
        return 'Upper + Calves';
      case WorkoutType.pull:
        return 'Pull';
      case WorkoutType.upper:
        return 'Upper Body';
      case WorkoutType.lower:
        return 'Lower Body';
      case WorkoutType.push:
        return 'Push';
    }
  }

  bool get isUpperBody =>
      this == WorkoutType.chestAndBack ||
      this == WorkoutType.shoulderAndArms ||
      this == WorkoutType.fullBody ||
      this == WorkoutType.upperAndCalves ||
      this == WorkoutType.push ||
      this == WorkoutType.pull ||
      this == WorkoutType.upper;
}

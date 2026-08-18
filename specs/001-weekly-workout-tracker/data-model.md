# Data Model: Weekly Workout Tracker

## Entities

### WorkoutType (Enum/Stable String)
Standardized domain concept for workout categories.
- `pull`
- `legs`
- `rest`
- `upper`
- `lower`
- `push`

### WorkoutDefinition
Static configuration for the Sama Fit program.
- `id`: String (matches WorkoutType value)
- `name`: String
- `exercises`: List<ExerciseSlot>

### ExerciseSlot
Defines an exercise's role in a specific workout.
- `exerciseId`: String (stable ID)
- `prescribedSets`: int
- `prescribedReps`: String (e.g., "8-12", "15-45s")
- `prescribedRest`: String
- `order`: int

### ExerciseDefinition
Static metadata for an exercise.
- `id`: String (e.g., "push_chest_press_machine")
- `name`: String
- `videoUrl`: String
- `isWeightAllowed`: bool
- `alternatives`: List<String> (Reference to other ExerciseDefinition IDs)

### WorkoutSession
A user's performed workout for a specific day.
- `dateKey`: String (Authoritative identity: `yyyy-MM-dd`)
- `workoutType`: String (matches WorkoutType)
- `exerciseLogs`: Map<String, ExerciseLog> (Key is `plannedExerciseId`)
- `displayUnit`: WeightUnit (Unit selected when session was saved)

### ExerciseLog
Record of a single exercise performance.
- `plannedExerciseId`: String
- `performedExerciseId`: String
- `weightKg`: double? (Canonical high-precision KG)
- `isPerformed`: bool
- `imagePath`: String? (Path to persistent storage)
- `timestamp`: DateTime

### WeightUnit (Enum)
- `kg`
- `lb`

## Identity & Uniqueness

1. **Exercise IDs**: Stable strings prefixed by workout type (e.g., `push_chest_press_machine`). Prefill is Workout-Specific per FR-003.

2. **Session Identity**: `dateKey` (`yyyy-MM-dd`). This is the authoritative identity used for lookup, duplicate prevention, and history navigation. A `DateTime` may be used in UI, but normalization to `dateKey` is mandatory for persistence.

## Persistence Schema (JSON)

Stored in `SharedPreferences` under key `WORKOUT_HISTORY_V1`.

```json
{
  "2026-08-18": {
    "workoutType": "push",
    "displayUnit": "kg",
    "exerciseLogs": {
      "push_chest_press_machine": {
        "performedExerciseId": "push_chest_press_machine",
        "weightKg": 45.0,
        "isPerformed": true,
        "imagePath": "/path/to/image.jpg"
      }
    }
  }
}
```

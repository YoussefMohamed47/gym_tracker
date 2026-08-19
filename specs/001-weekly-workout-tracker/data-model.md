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
- `sets`: List<ExerciseSetLog> (V2)
- `weightKg`: double? (Legacy V1 - kept for reading old data)
- `isPerformed`: bool (Legacy V1 - kept for reading old data)
- `imagePath`: String? (Path to persistent storage)
- `timestamp`: DateTime

### ExerciseSetLog (New in V2, Updated in V3)
- `weightKg`: double?
- `actualReps`: int? (New in V3)
- `isPerformed`: bool

## Identity & Uniqueness

1. **Exercise IDs**: Stable strings prefixed by workout type (e.g., `push_chest_press_machine`). Prefill is Workout-Specific per FR-003.

2. **Session Identity**: `dateKey` (`yyyy-MM-dd`). This is the authoritative identity used for lookup, duplicate prevention, and history navigation. A `DateTime` may be used in UI, but normalization to `dateKey` is mandatory for persistence.

## Persistence Schema (JSON)

Stored in `SharedPreferences` under key `WORKOUT_HISTORY_V1`.

### V2 Format (New)
```json
{
  "2026-08-19": {
    "workoutType": "pull",
    "displayUnit": "kg",
    "exerciseLogs": {
      "pull_t_bar_row": {
        "performedExerciseId": "pull_t_bar_row",
        "sets": [
          { "weightKg": 50.0, "isPerformed": true },
          { "weightKg": 52.5, "isPerformed": true },
          { "weightKg": 50.0, "isPerformed": true }
        ],
        "imagePath": "/path/to/image.jpg"
      }
    }
  }
}
```

### V1 Format (Legacy Support)
```json
{
  "2026-08-12": {
    "workoutType": "pull",
    "displayUnit": "kg",
    "exerciseLogs": {
      "pull_t_bar_row": {
        "performedExerciseId": "pull_t_bar_row",
        "weightKg": 45.0,
        "isPerformed": true
      }
    }
  }
}
```

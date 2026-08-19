# Data Model: App-Wide Local Database Migration

## Hive Boxes

| Box Name | Key Type | Value Type | Description |
|----------|----------|------------|-------------|
| `gym_tracker_daily_reports` | `String` (ID) | `DailyReportHiveModel` | Stores individual Daily Reports. |
| `gym_tracker_workout_sessions` | `String` (dateKey) | `WorkoutSessionHiveModel` | Stores aggregate Workout Sessions by date (yyyy-MM-dd). |
| `gym_tracker_settings` | `String` (Key) | `AppSettingsHiveModel` | Stores app-wide preferences like `WeightUnit`. |
| `gym_tracker_migration_meta` | `String` (Key) | `MigrationMetaHiveModel` | Stores migration status and versions. |

## Persistence Models (Hive Adapters)

### `DailyReportHiveModel` (TypeID: 0)
| Field ID | Name | Type | Description |
|----------|------|------|-------------|
| 0 | `id` | `String` | Unique report identity. |
| 1 | `breakfast` | `String` | Breakfast field. |
| 2 | `lunch` | `String` | Lunch field. |
| 3 | `snack` | `String` | Snack field. |
| 4 | `beforeTraining` | `String` | Before training field. |
| 5 | `afterTraining` | `String` | After training field. |
| 6 | `dinner` | `String` | Dinner field. |
| 7 | `water` | `String` | Water intake field. |
| 8 | `training` | `String` | Training notes. |
| 9 | `cardio` | `String` | Cardio notes. |
| 10 | `supplements` | `String` | Supplements notes. |
| 11 | `sleepTime` | `String` | Sleep duration/notes. |
| 12 | `notes` | `String?` | Optional additional notes. |
| 13 | `dateTime` | `DateTime?` | Date and time of the report. |
| 14 | `imagePath` | `String?` | **Relative path** from `appDocsDir` (moved from temp if legacy). |

### `WorkoutSessionHiveModel` (TypeID: 1)
| Field ID | Name | Type | Description |
|----------|------|------|-------------|
| 0 | `dateKey` | `String` | Identity (yyyy-MM-dd). |
| 1 | `workoutType` | `String` (Enum) | Type of workout (push, pull, etc.). |
| 2 | `exerciseLogs` | `List<ExerciseLogHiveModel>` | List of exercise performances. |
| 3 | `displayUnit` | `String` (Enum) | `kg` or `lb`. |

### `ExerciseLogHiveModel` (TypeID: 2)
| Field ID | Name | Type | Description |
|----------|------|------|-------------|
| 0 | `plannedExerciseId` | `String` | Original exercise ID. |
| 1 | `performedExerciseId` | `String` | Actually performed exercise ID. |
| 2 | `sets` | `List<ExerciseSetLogHiveModel>` | Per-set logs. |
| 3 | `weightKg` | `double?` | Legacy single-weight value. |
| 4 | `isPerformed` | `bool` | Completion status. |
| 5 | `imagePath` | `String?` | **Relative path** from `appDocsDir`. |
| 6 | `timestamp` | `DateTime` | Log time. |
| 7 | `displayUnit` | `String` | Display unit preference at time of log. |

### `ExerciseSetLogHiveModel` (TypeID: 3)
| Field ID | Name | Type | Description |
|----------|------|------|-------------|
| 0 | `setIndex` | `int` | Order of set. |
| 1 | `weightKg` | `double` | Canonical weight in KG. |
| 2 | `isPerformed` | `bool` | Completion status. |
| 3 | `actualReps` | `int?` | **New in V3**. Number of reps performed. |

### `AppSettingsHiveModel` (TypeID: 4)
| Field ID | Name | Type | Description |
|----------|------|------|-------------|
| 0 | `weightUnit` | `String` | Global preference `kg` or `lb`. |

### `MigrationMetaHiveModel` (TypeID: 5)
| Field ID | Name | Type | Description |
|----------|------|------|-------------|
| 0 | `state` | `int` | Map to `MigrationState` enum. |
| 1 | `lastAttempt` | `DateTime?` | Timestamp of last run. |
| 2 | `unresolvedCount` | `int` | Number of records that failed migration. |
| 3 | `version` | `int` | Schema/Migration version. |

## Migration Status Semantics
`MigrationState` enum values (mapped to `int` in Hive):
- `0: notStarted`: Fresh install or no migration run yet.
- `1: inProgress`: Migration logic is currently running.
- `2: completed`: All recognized legacy data successfully migrated and validated.
- `3: completedWithWarnings`: Some malformed/unresolved records remain in legacy source.
- `4: failed`: Fatal infrastructure error (e.g., Hive inaccessible).

## Migration Relationships
- `report_history` (JSON) -> Map to `DailyReportHiveModel`.
- `WORKOUT_HISTORY_V1` (JSON Map) -> Map each value to `WorkoutSessionHiveModel`.
- `WORKOUT_UNIT_PREFERENCE` (String) -> Map to `AppSettingsHiveModel.weightUnit`.

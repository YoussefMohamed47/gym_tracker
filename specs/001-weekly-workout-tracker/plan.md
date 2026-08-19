# Implementation Plan: Weekly Workout Tracker (EVOLUTION V3)

**Branch**: `001-weekly-workout-tracker` | **Date**: 2026-08-19 | **Spec**: [spec.md](spec.md)

**Input**: Revised requirements for per-set tracking, Daily Routine correction, and UI/UX polish.

## Summary

Evolve the existing Workout Tracker from a per-set weight model to a comprehensive repetition tracking system (Actual Reps Per Set - V3). This revision extends the set-level data model to include `actualReps` logged performance while preserving prescribed reps as program metadata. It implements a robust Hive schema evolution strategy (Field ID 3) and introduces a dual-input mobile UI for efficient gym performance logging. The technical approach leverages Hive CE for structured persistence, ensuring that legacy single-weight and per-set records remain readable without data fabrication.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.12+

**Primary Dependencies**: 
- `flutter_bloc` (State management with per-set draft tracking)
- `get_it` (DI for repositories and use cases)
- `shared_preferences` (JSON-based persistence with schema evolution)
- `url_launcher` (Exercise video support)
- `image_picker` (Progress photo support)

**Storage**: Hive CE is the source of truth for WorkoutSession, ExerciseLog, and WorkoutSetLog. SharedPreferences is used only as a legacy migration input for older released installations. New V3 workout writes remain Hive-only. The persistence structure uses typed aggregate records with stable Hive TypeAdapter field IDs.

**Legacy Compatibility**: V3 sessions will use the `actualReps` field (ID 3). V2 Hive records (without reps) and V1 SharedPreferences sessions (single-weight) remain readable. The repository and migrator handle polymorphic deserialization to ensure zero data loss.

**Testing**: 
- Canonical Daily Routine resolution tests.
- JSON serialization/deserialization regression tests (V1 and V2).
- Set-index prefill mapping logic.
- Cubit state transitions for multi-set editing.

## Constitution Check

- [x] **Feature Preservation**: Legacy single-weight sessions remain readable and shareable. Daily Report logic is untouched.
- [x] **Architecture**: strictly follows domain-driven feature-first layers. UI does not own persistence.
- [x] **Local-First**: No external APIs. All history and photos remain on-device.
- [x] **Data Integrity**: Canonical KG storage at the set level. Versioned JSON schema.
- [x] **UI Identity**: Material 3 redesign with the #1A46A0 brand. Optimized for one-handed set logging.
- [x] **Testing**: Extensive test suite covering migration and per-set edge cases.
- [x] **Simplicity**: Reuses existing catalog and repository patterns without adding heavy new dependencies.

## Project Structure

### Documentation (this feature)

```text
specs/001-weekly-workout-tracker/
├── spec.md              # Authoritative V2 requirements
├── plan.md              # This technical design
├── research.md          # Updated for V2 persistence decisions
├── data-model.md        # V2 Entities and JSON schema
├── quickstart.md        # Updated validation scenarios
└── checklists/
    └── requirements.md  # Acceptance criteria
```

### Source Code (repository root)

```text
lib/
├── features/
│   └── workout/
│       ├── data/
│       │   ├── models/
│       │   │   ├── exercise_set_log_model.dart  # [NEW]
│       │   │   └── exercise_log_model.dart      # [UPDATED] V1/V2 aware
│       │   └── repositories/
│       │       └── workout_repository_impl.dart  # [UPDATED] Per-set lookup
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── exercise_set_log.dart        # [NEW]
│       │   │   └── exercise_log.dart            # [UPDATED]
│       │   └── usecases/
│       │       └── get_exercise_history.dart    # [NEW]
│       └── presentation/
│           ├── cubit/
│           │   ├── workout_cubit.dart           # [UPDATED] Draft management
│           │   └── workout_state.dart           # [UPDATED]
│           ├── widgets/
│           │   ├── exercise_card.dart           # [REDESIGN]
│           │   ├── exercise_set_row.dart        # [NEW]
│           │   ├── exercise_history_sheet.dart  # [NEW]
│           │   └── workout_week_selector.dart   # [REDESIGN]
```

## Data Model Revision & Legacy Strategy

### 1. ExerciseLog Evolution
The `ExerciseLog` entity now primarily manages a `List<ExerciseSetLog>`. 
*   **V2 Storage**: Saves the `sets` array.
*   **V1 Storage**: Historical records containing `weightKg` and `isPerformed` at the exercise level are treated as "Legacy Reference" data.
*   **Reading Logic**: The `ExerciseLogModel.fromJson` factory checks for the presence of the `sets` key. If missing, it maps the V1 fields into a virtual summary for UI presentation.

### 2. Prefill & History Lookup
*   **Exact Match**: Set N for today's exercise prefills from Set N of the most recent *same* exercise in the *same* `WorkoutType`.
*   **Polymorphic History**: The `GetPreviousExerciseLog` use case returns a `PreviousPerformance` object containing the `dateKey` and the log data (either set-based or legacy).
*   **Legacy Reference**: If the previous session is V1, the UI displays "Previous: 50 kg" as a reference label with a "Use for all sets" action.

## UI/UX Redesign Plan

### 1. Workout Screen Hierarchy
*   **Sticky Header**: Workout name, Week selector, and share/history actions.
*   **Week Selector**: Compact 7-day strip with status indicators (completed/rest).
*   **Exercise List**: Scrollable list of `ExerciseCard`s.
*   **Sticky Save Bar**: Always visible at the bottom with a summary of performed exercises.

### 2. Exercise Card Design
*   **Top Row**: Exercise Name, Video Icon, Alternative Selector.
*   **Meta Row**: Prescribed Sets/Reps/Rest, Previous Date label.
*   **Set Table**: 
    *   Headers: SET | LAST | TODAY | DONE.
    *   Rows: Individual `ExerciseSetRow` widgets with numeric inputs.
*   **Bottom Actions**: History, Photo.

### 3. Input UX
*   **Numeric Keyboard**: Decimal-friendly.
*   **Focus Cycle**: Tapping "Done" on the keyboard or a specific "Next" action moves focus to the weight input of the subsequent set.
*   **Performed State**: Explicit checkbox/toggle for each set.

## Daily Routine Implementation
*   **Data Source**: `WorkoutCatalog.getDailyRoutine()` is the single source of truth.
*   **Bug Fix**: Remove all hardcoded ID strings from the Cubit/UI. The Cubit will request the routine from the catalog by ID `daily_routine`.
*   **Set Handling**: Even non-weight routine exercises display their prescribed sets (e.g., 2 sets for SLR) for completion tracking.

## Sharing Evolution
*   **Workout Share**: Iterates over performed exercises. For V2 logs, it prints `S1 50 | S2 50 | S3 47.5`. For V1 logs, it prints `50 kg`.
*   **Week Share**: Condensed view showing training days and total exercises performed.

## Testing Strategy
*   **Unit**: 
    *   `WorkoutCatalog` regression (exact routine members).
    *   `ExerciseLogModel` V1/V2 compatibility.
    *   `WeightConverter` per-set precision.
*   **Bloc**:
    *   Alternative draft preservation (switching back and forth preserves arrays).
    *   Partial completion save validation.
*   **Widget**:
    *   Exercise card set row count validation (2 vs 3 vs 5).

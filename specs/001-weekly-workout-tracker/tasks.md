# Tasks: Weekly Workout Tracker (EVOLUTION V3)

**Input**: Design documents from `/specs/001-weekly-workout-tracker/`

**Prerequisites**: plan.md (V3), spec.md (V3), data-model.md (V3)

**Organization**: Tasks are grouped by logical layer to ensure dependency-safe evolution of the repetition tracking feature.

---

## Phase 8: Evolution V3 - Actual Reps Per Set (Blocking)

**Purpose**: Evolve the domain and persistence layers to support repetition tracking while maintaining Hive schema stability.

- [ ] T040 Update `ExerciseSetLog` domain entity with `actualReps` field in `lib/features/workout/domain/entities/exercise_set_log.dart`
- [ ] T041 [P] Add `actualReps` to `ExerciseSetLogHiveModel` using **NEW Field ID 3** in `lib/features/workout/data/models/exercise_set_log_hive_model.dart`
- [ ] T042 Generate Hive adapters: `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] T043 [P] Implement backwards compatibility tests covering the full historical upgrade path: legacy SharedPreferences workout JSON -> existing legacy migrator -> Hive WorkoutSession aggregate -> WorkoutSetLog records compatible with V3.
    - [ ] Case 1: Old Hive per-set record (weightKg=50, actualReps absent) -> V3 result (actualReps=null)
    - [ ] Case 2: Legacy SP single-weight record -> V3 history remains legacy weight only
    - [ ] Case 3: Legacy SP per-set record without reps -> V3 result (actualReps=null)
    - [ ] Case 4: New V3 Hive record (weight + reps) -> round-trip integrity
    - [ ] Verify stale SharedPreferences data never overwrites existing valid Hive data.
- [ ] T044 Update `WorkoutLocalDataSource` mappers to support `actualReps` in `lib/features/workout/data/datasources/workout_local_datasource.dart`
- [ ] T045 [P] Update `WorkoutRepositoryImpl` to include reps in previous-exercise lookup and history in `lib/features/workout/data/repositories/workout_repository_impl.dart`

**Checkpoint**: V3 Foundation ready - persistence and repository layers support repetition tracking.

---

## Phase 9: V3 Logic & State Management

**Purpose**: Update the business logic to handle dual-data prefill (Weight + Reps) and auto-performance triggers.

- [ ] T046 [US1] Update `WorkoutCubit` to handle `actualReps` updates and auto-performed state in `lib/features/workout/presentation/cubit/workout_cubit.dart`
- [ ] T047 [US1] Implement per-set reps prefill logic (matching set index) in `WorkoutCubit._createInitialLog` in `lib/features/workout/presentation/cubit/workout_cubit.dart`
- [ ] T048 [P] [US1] Implement independent rep draft preservation for alternatives in `lib/features/workout/presentation/cubit/workout_cubit.dart`
- [ ] T049 [US1] Unit test for V3 Cubit transitions (reps update, prefill, partial completion) in `test/features/workout/presentation/cubit/workout_cubit_test.dart`

---

## Phase 10: V3 UI Evolution & Interaction

**Purpose**: Redesign the logging UI to support dual-input focus flow and duration-based exercises.

- [ ] T050 [P] [US1] Update `ExerciseSetRow` for Actual Reps input in `lib/features/workout/presentation/widgets/exercise_set_row.dart`
    - [ ] Add integer-only Actual Reps input for repetition-based sets.
    - [ ] Use the approved integer numeric keyboard.
    - [ ] Blank remains valid.
    - [ ] Reject zero, negative, decimal, or otherwise invalid rep values.
    - [ ] Display the approved inline validation message: "Reps must be greater than 0"
    - [ ] Do not silently clear, clamp, or replace invalid input.
    - [ ] Invalid reps must not be persisted.
    - [ ] Preserve logical Weight → Reps focus flow.
    - [ ] Preserve narrow-screen responsiveness and accessibility semantics.
- [ ] T051 [US1] Implement dual-input focus behavior (Weight -> Reps -> Next Set Weight) in `lib/features/workout/presentation/widgets/exercise_log_card.dart`
- [ ] T052 [US1] Implement conditional rep-input visibility based on prescription (Duration-based exercises omit reps) in `lib/features/workout/presentation/widgets/exercise_log_card.dart`
- [ ] T053 [P] [US1] Update `ExerciseHistorySheet` to display `weight × reps` per set with legacy handling in `lib/features/workout/presentation/widgets/exercise_history_sheet.dart`
- [ ] T054 [P] [US1] Update Daily Routine UI to support numeric reps for repetition movements in `lib/features/workout/presentation/widgets/daily_routine_section.dart`

---

## Phase 11: V3 Sharing & Final Polish

**Purpose**: Update sharing templates to reflect training volume accurately.

- [ ] T055 [P] Update `WorkoutShareCard` with detailed `S1: 52.5 kg × 10` format and legacy weight-only fallback in `lib/features/workout/presentation/widgets/share/workout_share_card.dart`
- [ ] T056 [P] Update `WeeklyWorkoutShareCard` with compact `52.5kg×10` performance format in `lib/features/workout/presentation/widgets/share/weekly_workout_share_card.dart`
- [ ] T057 [P] Verify `weight × reps` sharing format for bodyweight repetition exercises (e.g., "12 reps")
- [ ] T058 [P] Verify KG/LB unit conversion only affects weight, never reps.

---

## Phase 12: V3 Quality Assurance

- [ ] T059 Run `dart format .`
- [ ] T060 Run `flutter analyze`
- [ ] T061 Run all tests (`flutter test`) covering model, repository, cubit, and sharing
- [ ] T062 Execute manual verification for:
    - [ ] 2-set rep tracking
    - [ ] 5-set Daily Routine reps
    - [ ] Duration-based exercise (no reps)
    - [ ] Alternative switching preservation
    - [ ] Legacy session sharing (no crash, no "null" labels)

---

## Dependencies & Execution Order

1. **Phase 8 (Foundation)**: MUST be completed first. BLOCKS all logic and UI work.
2. **T042 (Adapter Generation)**: Depends on T041. MUST run before T043.
3. **Phase 9 (Cubit)**: Depends on Phase 8.
4. **Phase 10 (UI)**: Depends on Phase 9.
5. **Phase 11 (Sharing)**: Can run in parallel with Phase 10.

# Tasks: Weekly Workout Tracker (EVOLUTION V2)

**Input**: Design documents from `/specs/001-weekly-workout-tracker/`

**Prerequisites**: plan.md (V2), spec.md (V2), data-model.md (V2), research.md (V2)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing. Foundational migration and data model tasks are prioritized to unblock all UI work.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Update `pubspec.yaml` with latest stable `url_launcher` and `image_picker` dependencies
- [ ] T002 Ensure project directory structure matches feature-first architecture in `lib/features/workout/`
- [ ] T003 [P] Add #1A46A0 brand color constant in `lib/core/utils/colors.dart` (if not present)

---

## Phase 2: Foundational (V2 Data Model & Migration - BLOCKING)

**Purpose**: Core infrastructure that MUST be complete before ANY V2 user story can be implemented.

- [ ] T004 Implement `ExerciseSetLog` entity in `lib/features/workout/domain/entities/exercise_set_log.dart`
- [ ] T005 [P] Implement `ExerciseSetLogModel` (JSON) in `lib/features/workout/data/models/exercise_set_log_model.dart`
- [ ] T006 [P] Update `ExerciseLog` entity to support `List<ExerciseSetLog> sets` in `lib/features/workout/domain/entities/exercise_log.dart`
- [ ] T007 [P] Implement polymorphic JSON deserialization in `ExerciseLogModel.fromJson` to handle V1 (`weightKg`) and V2 (`sets`) in `lib/features/workout/data/models/exercise_log_model.dart`
- [ ] T008 [P] Implement unit tests for V1/V2 JSON compatibility in `test/features/workout/data/models/exercise_log_model_test.dart`
- [ ] T009 Update `WorkoutSession` model to support the new `ExerciseLog` structure in `lib/features/workout/data/models/workout_session_model.dart`
- [ ] T010 [P] Implement high-precision KG weight storage at the set level in `lib/features/workout/data/models/exercise_set_log_model.dart`
- [ ] T011 Update `WorkoutLocalDataSource` to support versioned schema reads in `lib/features/workout/data/datasources/workout_local_datasource.dart`

**Checkpoint**: Foundation ready - legacy data can be read, and new set-level data can be persisted.

---

## Phase 3: User Story 3 - Daily Routine Correctness (Priority: P1) 🎯

**Goal**: Fix the "Unknown Exercise" bug and ensure routine is strictly data-driven from the catalog.

**Independent Test**: Daily Routine contains exactly 5 canonical exercises with functional video links and no placeholders.

- [ ] T012 [P] Identify and remove hardcoded placeholder routine ID strings in `lib/features/workout/presentation/cubit/workout_cubit.dart`
- [ ] T013 [P] Correct `WorkoutCatalog.getDailyRoutine()` to return EXACTLY the 5 exercises: SLR, Clam shell, neurodynamic sciatic nerve, Trunk rotation, Double knee to chest in `lib/features/workout/data/datasources/workout_catalog.dart`
- [ ] T014 [P] Verify `WorkoutCatalog` regression tests match the canonical Sama Fit PDF specs in `test/features/workout/data/datasources/workout_catalog_test.dart`
- [ ] T015 Update `WorkoutCubit` to resolve the routine solely via `WorkoutCatalog.getDailyRoutine()`

---

## Phase 4: User Story 1 - Per-Set Workout Flow (Priority: P1) 🎯 MVP

**Goal**: Record independent weights and performance for EACH prescribed set.

**Independent Test**: 3-set exercise allows entering 3 weights, marking each as done, and saving to history.

### Tests for User Story 1 (REQUIRED) ⚠️

- [ ] T016 [US1] Unit test for per-set weight mapping (Set N prefills from Previous Set N) in `test/features/workout/domain/repositories/workout_repository_test.dart`
- [ ] T017 [US1] Unit test for partial completion logic (Exercise is performed if >=1 set is done) in `test/features/workout/presentation/cubit/workout_cubit_test.dart`

### Implementation for User Story 1

- [ ] T018 [US1] Update `WorkoutState` to store per-set draft data in `lib/features/workout/presentation/cubit/workout_state.dart`
- [ ] T019 [P] [US1] Implement `ExerciseSetRow` widget with numeric input, "Last" label, and performance toggle in `lib/features/workout/presentation/widgets/exercise_set_row.dart`
- [ ] T020 [P] [US1] Redesign `ExerciseCard` to include set rows and prescribed meta in `lib/features/workout/presentation/widgets/exercise_card.dart`
- [ ] T021 [US1] Revise `WorkoutCubit` to handle per-set weight/performed state updates in `lib/features/workout/presentation/cubit/workout_cubit.dart`
- [ ] T022 [US1] Implement numeric keyboard focus management (Next moves to next set input) in `lib/features/workout/presentation/widgets/exercise_set_row.dart`
- [ ] T023 [US1] Implement alternative set draft isolation (switching back and forth preserves independent set arrays) in `lib/features/workout/presentation/cubit/workout_cubit.dart`
- [ ] T024 [US1] Redesign `WorkoutScreen` with sticky header, 7-day week selector, and sticky save bar in `lib/features/workout/presentation/view/workout_screen.dart`

**Checkpoint**: Core V2 per-set logging is functional.

---

## Phase 5: User Story 2 - Exercise History & Reference (Priority: P2)

**Goal**: View previous session dates and per-set history directly within the workout context.

**Independent Test**: Tapping History opens a bottom sheet showing multiple dated sessions with set breakdowns.

- [ ] T025 [P] [US2] Implement `GetExerciseHistory` use case to retrieve multiple dated performances in `lib/features/workout/domain/usecases/get_exercise_history.dart`
- [ ] T026 [US2] Create `ExerciseHistoryBottomSheet` showing per-set history list in `lib/features/workout/presentation/widgets/exercise_history_sheet.dart`
- [ ] T027 [US2] Update `ExerciseCard` to display "Previous Workout Date" label in `lib/features/workout/presentation/widgets/exercise_card.dart`
- [ ] T028 [US2] Integrate `ExerciseHistoryBottomSheet` into `ExerciseCard` actions

---

## Phase 6: User Story 4 - Legacy Data Integrity (Priority: P2)

**Goal**: Seamlessly handle V1 single-weight history records.

**Independent Test**: Historical V1 session displays "Legacy single-weight record" and can initialize today's sets.

- [ ] T029 [US4] Implement "Legacy Working Weight" UI reference for V1 previous sessions in `lib/features/workout/presentation/widgets/exercise_card.dart`
- [ ] T030 [US4] Implement "Use legacy weight for all sets" draft initialization action in `lib/features/workout/presentation/cubit/workout_cubit.dart`
- [ ] T031 [US4] Verify sharing handles legacy V1 logs by showing single weight instead of set list in `lib/features/workout/presentation/widgets/share/workout_share_card.dart`

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final quality checks and cross-feature integration.

- [ ] T032 Update `WorkoutShareCard` to display per-set values (e.g., "50 | 50 | 47.5") for V2 sessions
- [ ] T033 [P] Verify text scaling and Material 3 brand identity consistency across all redesigned UI
- [ ] T034 [P] Verify existing photo/report navigation remains functional
- [ ] T035 [P] Verify compliance with Project Constitution principles
- [ ] T036 Run `dart format .`
- [ ] T037 Run `flutter analyze`
- [ ] T038 Run all tests (`flutter test`)
- [ ] T039 Execute manual UX verification via `quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup. BLOCKS all UI work.
- **Daily Routine (Phase 3)**: Can run in parallel with Foundational.
- **User Stories (Phase 4-6)**: Depends on Foundational completion.
- **Polish (Phase 7)**: Depends on all user stories.

### User Story Dependencies

- **US1 (MVP)**: Must be first UI story.
- **US2, US4**: Depend on US1 foundation (ExerciseCard redesign).

---

## Parallel Execution Opportunities

- All Phase 1 tasks.
- Foundational tasks (T005-T008, T010).
- Daily Routine identification (T012-T014) can start during Foundation.
- Redesigning widgets (T019, T020) can start once domain entities (T004, T006) are stable.
- Polish phase verification tasks.

---

## Implementation Strategy

### Revision First (Foundation + US3)

1. Complete Phase 2: Foundational (Migration safety is priority).
2. Complete Phase 3: Daily Routine fix (Low risk, high impact bug fix).

### Incremental Evolution (US1)

1. Redesign `ExerciseCard` and `WorkoutScreen` structure.
2. Implement per-set logic in `WorkoutCubit`.
3. **STOP and VALIDATE**: Verify 3-set exercises log correctly and V1 history doesn't crash.

### Contextual Polish (US2 + US4)

1. Add History Bottom Sheet.
2. Add Legacy reference actions.
3. Update Sharing.

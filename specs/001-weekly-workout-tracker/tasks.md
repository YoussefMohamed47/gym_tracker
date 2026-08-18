# Tasks: Weekly Workout Tracker

**Input**: Design documents from `/specs/001-weekly-workout-tracker/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing. Foundational tasks (models, persistence, utils) are grouped in Phase 2.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project directory structure under lib/features/workout/
- [ ] T002 Update pubspec.yaml with url_launcher and image_picker dependencies
- [ ] T003 [P] Add #1A46A0 brand color constant in lib/core/utils/colors.dart (if not present)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure including models, utilities, and persistence that MUST be complete before UI work begins.

- [ ] T004 Implement WeightUnit enum and WeightConverter utility (1 kg = 2.20462262185 lb) in lib/core/utils/weight_converter.dart
- [ ] T005 Create WorkoutType and WorkoutDefinition entities in lib/features/workout/domain/entities/
- [ ] T006 Define static workout catalog using Authoritative Weekly Schedule from spec.md in lib/features/workout/data/datasources/workout_catalog.dart
- [ ] T007 [P] Create ExerciseLog and WorkoutSession entities (using String dateKey) in lib/features/workout/domain/entities/
- [ ] T008 [P] Create ExerciseLogModel and WorkoutSessionModel (JSON serialization) in lib/features/workout/data/models/
- [ ] T009 Implement WorkoutLocalDataSource with SharedPreferences in lib/features/workout/data/datasources/workout_local_datasource.dart
- [ ] T010 Implement WorkoutRepository and RepositoryImpl in lib/features/workout/domain/repositories/ and lib/features/workout/data/repositories/
- [ ] T011 Create UseCase for GetWorkoutForDate (enforcing yyyy-MM-dd dateKey normalization) in lib/features/workout/domain/usecases/get_workout_for_date.dart
- [ ] T012 Create UseCase for SaveWorkoutSession (handling photo cleanup) in lib/features/workout/domain/usecases/save_workout_session.dart
- [ ] T013 Create UseCase for GetPreviousExerciseLog (Workout-Specific logic) in lib/features/workout/domain/usecases/get_previous_exercise_log.dart
- [ ] T014 Register Workout dependencies in lib/core/di/injection_container.dart

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Main Workout Flow (Priority: P1) 🎯 MVP

**Goal**: Display prescribed exercises, allow weight entry, and save session to history.

**Independent Test**: Select Saturday (Push), enter weights for all exercises, save, restart app, and verify data persists.

### Tests for User Story 1 (REQUIRED) ⚠️

- [ ] T015 [P] [US1] Unit test for WeightConverter round-trip precision in test/core/utils/weight_converter_test.dart
- [ ] T016 [P] [US1] Unit test for Sunday-Saturday week calculation and yyyy-MM-dd dateKey normalization in test/features/workout/utils/date_utils_test.dart
- [ ] T017 [US1] Unit test for WorkoutRepository prefill and duplicate dateKey prevention in test/features/workout/domain/repositories/workout_repository_test.dart

### Implementation for User Story 1

- [ ] T018 [US1] Implement WorkoutState with selectedDate, dateKey, and exerciseLogs in lib/features/workout/presentation/cubit/workout_state.dart
- [ ] T019 [US1] Implement WorkoutCubit with "Review Workout" save confirmation logic in lib/features/workout/presentation/cubit/workout_cubit.dart
- [ ] T020 [US1] Create WorkoutWeekHeader and WeekDaySelector widgets in lib/features/workout/presentation/widgets/
- [ ] T021 [US1] Create ExerciseLogCard with weight input and confirmed status indicator in lib/features/workout/presentation/widgets/exercise_log_card.dart
- [ ] T022 [US1] Implement WorkoutScreen with day selector and "Photo unavailable" state handling in lib/features/workout/presentation/view/workout_screen.dart
- [ ] T023 [US1] Add "Daily Routine" section to WorkoutScreen in lib/features/workout/presentation/widgets/daily_routine_section.dart
- [ ] T024 [US1] Implement "Edit History" mode loading sessions by dateKey in lib/features/workout/presentation/cubit/workout_cubit.dart

**Checkpoint**: MVP workout logging is functional and persistent.

---

## Phase 4: User Story 2 - Weight Unit Support & Conversion (Priority: P1)

**Goal**: Toggle between KG and LB globally while preserving high-precision stored data.

**Independent Test**: Record 100 kg, switch to LB (verify ~220.5 lb), switch back to KG (verify exactly 100 kg).

- [ ] T025 [P] [US2] Implement WeightUnitSelector widget in lib/features/workout/presentation/widgets/weight_unit_selector.dart
- [ ] T026 [US2] Integrate unit toggle in WorkoutCubit without mutating stored weights in lib/features/workout/presentation/cubit/workout_cubit.dart
- [ ] T027 [US2] Update ExerciseLogCard to handle high-precision display conversion in lib/features/workout/presentation/widgets/exercise_log_card.dart

---

## Phase 5: User Story 3 - Exercise Alternatives (Priority: P2)

**Goal**: Select curated alternatives for exercises with isolated draft states.

**Independent Test**: Replace Chest Press with DB Bench, toggle back and forth, verify draft weights are preserved separately.

- [ ] T028 [US3] Define ExerciseAlternative model and curated replacement matrix in lib/features/workout/data/datasources/replacement_matrix.dart
- [ ] T029 [US3] Create AlternativeExerciseBottomSheet for selection in lib/features/workout/presentation/widgets/alternative_exercise_bottom_sheet.dart
- [ ] T030 [US3] Update WorkoutCubit to preserve in-session drafts for original and alternatives separately in lib/features/workout/presentation/cubit/workout_cubit.dart
- [ ] T031 [US3] Update ExerciseLogCard to display "Planned -> Performed" identity for selected alternatives in lib/features/workout/presentation/widgets/exercise_log_card.dart

---

## Phase 6: User Story 4 - Media & Photos (Priority: P3)

**Goal**: External video launching and per-session photo reference logging with failure resilience.

**Independent Test**: Replacement of photo safely deletes old file only after new one is persisted. Missing file does not crash UI.

- [ ] T032 [P] [US4] Implement VideoLauncher utility using url_launcher in lib/features/workout/presentation/utils/video_launcher.dart
- [ ] T033 [US4] Implement PhotoService with atomic replacement and "Disk Full" handling in lib/features/workout/presentation/services/photo_service.dart
- [ ] T034 [US4] Add video/photo actions to ExerciseLogCard with missing-file graceful handling in lib/features/workout/presentation/widgets/exercise_log_card.dart
- [ ] T035 [US4] Implement physical file deletion and missing-file resilience in SaveWorkoutSession in lib/features/workout/domain/usecases/save_workout_session.dart

---

## Phase 7: User Story 5 - Sharing & History (Priority: P3)

**Goal**: Branded image generation for single workouts and detailed weekly summaries.

**Independent Test**: Share Week contains full exercise lists for all saved days without including private photos.

- [ ] T036 [P] [US5] Create WorkoutShareCard template in lib/features/workout/presentation/widgets/share/workout_share_card.dart
- [ ] T037 [P] [US5] Create detailed WeeklyWorkoutShareCard template in lib/features/workout/presentation/widgets/share/weekly_workout_share_card.dart
- [ ] T038 [US5] Implement WorkoutShareService using existing WidgetImageCapture in lib/features/workout/presentation/services/workout_share_service.dart
- [ ] T039 [US5] Add Share action to WorkoutScreen header in lib/features/workout/presentation/view/workout_screen.dart

---

## Phase 8: Polish & Top-Level Integration

**Purpose**: Integration with main app navigation and final quality checks.

- [ ] T040 Integrate Workout route in lib/core/router/app_router.dart
- [ ] T041 Implement Material 3 NavigationBar on MainScreen to switch between Report and Workout in lib/features/main/presentation/view/main_screen.dart
- [ ] T042 [P] Verify existing Daily Report flow and History restore functionality still work.
- [ ] T043 [P] Verify compliance with Project Constitution principles.
- [ ] T044 Run dart format .
- [ ] T045 Run flutter analyze
- [ ] T046 Run flutter test (all suites)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup (T001-T003). BLOCKS all UI work.
- **User Stories (Phase 3-7)**: All depend on Foundational (Phase 2) completion.
- **Integration (Phase 8)**: Depends on at least US1 (MVP) being complete.

### User Story Dependencies

- **US1 (MVP)**: Mandatory first story.
- **US2, US3, US4, US5**: Can proceed in parallel after US1 foundation is laid.

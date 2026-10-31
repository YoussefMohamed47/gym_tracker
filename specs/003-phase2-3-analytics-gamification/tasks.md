# Tasks: Phase 2 (Gamification) & Phase 3 (Advanced Analytics)

**Input**: Design documents from `/specs/003-phase2-3-analytics-gamification/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Add `confetti` and `fl_chart` packages to `pubspec.yaml`
- [x] T002 [P] Fetch dependencies by running `flutter pub get`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Ensure dependency injection framework (`get_it`) is correctly set up for new feature modules in `lib/core/di/` or `lib/main.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Confetti on PR (Priority: P1) 🎯 MVP

**Goal**: Display a confetti animation when a user logs a Personal Record (PR) to motivate and reward their progress.

**Independent Test**: Log a set with higher weight or reps than historically recorded for the same exercise and observe the visual confetti effect in the UI.

### Implementation for User Story 1

- [x] T004 [P] [US1] Create `CheckPRUseCase` in `lib/features/workout/domain/usecases/check_pr_usecase.dart`
- [x] T005 [US1] Register `CheckPRUseCase` in dependency injection configuration
- [x] T006 [US1] Update `WorkoutCubit` to check for PR when a set is saved, adding PR state flag in `lib/features/workout/presentation/cubit/workout_cubit.dart`
- [x] T007 [US1] Add `ConfettiController` and `ConfettiWidget` to `ExerciseSetRow` (or `WorkoutScreen`) and play animation on PR state change in `lib/features/workout/presentation/widgets/exercise_set_row.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - 30-Day Volume Chart (Priority: P1)

**Goal**: View a line chart of 30-day training volume (tonnage) to visualize workload trends over time.

**Independent Test**: Navigate to the Report History Screen Analytics Tab and verify that the volume line chart plots tonnage for the past 30 days.

### Implementation for User Story 2

- [x] T008 [P] [US2] Create `VolumeDataPoint` and `VolumeTonnageReport` domain models in `lib/features/workout/domain/models/volume_data_point.dart`
- [x] T009 [US2] Create `Get30DayVolumeTonnageUseCase` in `lib/features/workout/domain/usecases/get_30_day_volume_usecase.dart`
- [x] T010 [US2] Register `Get30DayVolumeTonnageUseCase` in dependency injection configuration
- [x] T011 [P] [US2] Create `VolumeLineChart` widget using `fl_chart` in `lib/features/daily_report/presentation/widgets/volume_line_chart.dart`
- [x] T012 [US2] Integrate `VolumeLineChart` into Analytics Tab of `ReportHistoryScreen` in `lib/features/daily_report/presentation/view/report_history_screen.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Meal Adherence Radar Chart (Priority: P2)

**Goal**: See a radar chart of meal adherence to understand nutritional consistency at a glance.

**Independent Test**: Navigate to the Analytics view and verify the chart correctly reflects macro/meal adherence scores based on logged daily reports.

### Implementation for User Story 3

- [x] T013 [P] [US3] Create `MealAdherenceDataPoint` domain model in `lib/features/daily_report/domain/models/meal_adherence_data_point.dart`
- [x] T014 [US3] Create `GetMealAdherenceUseCase` in `lib/features/daily_report/domain/usecases/get_meal_adherence_usecase.dart`
- [x] T015 [US3] Register `GetMealAdherenceUseCase` in dependency injection configuration
- [x] T016 [P] [US3] Create `MealAdherenceRadarChart` widget using `fl_chart` in `lib/features/daily_report/presentation/widgets/meal_adherence_radar_chart.dart`
- [x] T017 [US3] Integrate `MealAdherenceRadarChart` into Analytics Tab of `ReportHistoryScreen` alongside `VolumeLineChart` in `lib/features/daily_report/presentation/view/report_history_screen.dart`

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T018 [P] Verify compliance with Project Constitution principles (Material 3 UI/UX, feature-first architecture, no direct Hive access from UI)
- [x] T019 [P] Write unit tests for new UseCases in `test/features/workout/domain/usecases/` and `test/features/daily_report/domain/usecases/`
- [x] T020 Run `flutter analyze` and `flutter test` to ensure code quality
- [x] T021 Manual end-to-end testing of Analytics layout on different mobile device screen sizes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Independent of US1 but shares UI space with US2

### Within Each User Story

- Models before services/usecases
- Services/usecases before UI integration
- Core implementation before UI Polish
- Story complete before moving to next priority

### Parallel Opportunities

- After T003, developers can work on US1 (Confetti), US2 (Volume Chart), and US3 (Meal Adherence Chart) in parallel.
- Within US2 and US3, UI widget creation (T011, T016) can be done in parallel with Domain logic creation (T008, T013).
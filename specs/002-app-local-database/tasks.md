---
description: "Task list for App-Wide Local Database Migration (Hive CE)"
---

# Tasks: App-Wide Local Database Migration

**Input**: Design documents from `/specs/002-app-local-database/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic Hive structure

- [x] T001 Add `hive_ce`, `hive_ce_flutter` to `dependencies` and `hive_ce_generator`, `build_runner` to `dev_dependencies` in `pubspec.yaml`
- [x] T002 Create `lib/core/storage/hive/hive_boxes.dart` and define box names per `research.md`
- [x] T003 Create `lib/core/storage/hive/hive_registrar.dart` to manage adapter registration
- [x] T004 Create `lib/core/storage/hive/hive_local_storage.dart` as the low-level Hive wrapper
- [x] T005 [P] Create `lib/core/storage/migration/migration_result.dart` to represent migration outcomes

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Hive models, adapter generation, and failure handling. MUST be complete before ANY feature implementation.

- [x] T006 Create `lib/features/daily_report/data/models/daily_report_hive_model.dart` with `@HiveType(typeId: 0)`
- [x] T007 [P] Create `lib/features/workout/data/models/workout_session_hive_model.dart` with `@HiveType(typeId: 1)`
- [x] T008 [P] Create `lib/features/workout/data/models/exercise_log_hive_model.dart` with `@HiveType(typeId: 2)`
- [x] T009 [P] Create `lib/features/workout/data/models/exercise_set_log_hive_model.dart` with `@HiveType(typeId: 3)`
- [x] T010 [P] Create `lib/core/storage/hive/models/app_settings_hive_model.dart` with `@HiveType(typeId: 4)`
- [x] T011 [P] Create `lib/core/storage/hive/models/migration_meta_hive_model.dart` with `@HiveType(typeId: 5)`
- [x] T012 **(SEQUENTIAL)** Run `flutter pub run build_runner build --delete-conflicting-outputs`. Depends on T006-T011 completion.
- [x] T013 Update `lib/core/storage/hive/hive_registrar.dart` to register all generated adapters
- [x] T014 [P] Create `test/core/storage/hive/hive_adapter_test.dart` to verify round-trip stability for all models (including defaults)
- [x] T015 Implement "Storage Error" UI/Logic in `lib/features/main/presentation/view/main_screen.dart` (or bootstrap state) to handle initialization/corruption failure

**Checkpoint**: Foundational Hive infrastructure and failure safety ready.

---

## Phase 3: User Story 1 - Seamless Legacy Migration (Priority: P1) 🎯 MVP

**Goal**: Automatically move historical workout data and daily reports to Hive from SharedPreferences.

**Independent Test**: Seed `SharedPreferences` with legacy JSON and verify Hive content after `LegacyPersistenceMigrator` execution.

### Tests for User Story 1
- [x] T016 Create `test/core/storage/migration/legacy_persistence_migrator_test.dart` (TDD: Write tests for US1 scenarios)

### Implementation for User Story 1
- [x] T017 [US1] Implement `DailyReport` parser in `lib/core/storage/migration/legacy_persistence_migrator.dart`
- [x] T018 [US1] Implement `WorkoutSession` (V1 & V2) parser in `lib/core/storage/migration/legacy_persistence_migrator.dart`
- [x] T019 [US1] Implement `WeightUnit` settings parser in `lib/core/storage/migration/legacy_persistence_migrator.dart`
- [x] T020 [US1] Implement deterministic key logic (`reportId`, `dateKey`) and **"Hive Wins"** conflict resolution (do not overwrite existing Hive data)
- [x] T021 [US1] Implement migration completion marker persistence in `LegacyPersistenceMigrator`
- [x] T022 [US1] Implement cleanup of recognized SharedPreferences keys ONLY after validated success of ALL records in that key

**Checkpoint**: Core migration engine functional.

---

## Phase 4: User Story 2 - Failure-Safe & Idempotent Retry (Priority: P1)

**Goal**: Resilience to crashes and malformed data during migration.

### Tests for User Story 2
- [x] T023 [US2] Add "Interrupted Migration" tests to `test/core/storage/migration/legacy_persistence_migrator_test.dart`
- [x] T024 [US2] Add "Malformed JSON" recovery tests (skip corrupted, rescue valid)

### Implementation for User Story 2
- [x] T025 [US2] Implement skip-and-log logic for malformed individual records in `LegacyPersistenceMigrator`
- [x] T026 [US2] Ensure `SharedPreferences` keys are NOT deleted if any record fails migration/validation

---

## Phase 5: File Persistence & Media Rescue (Critical Safety)

**Purpose**: Move history-critical images from temp to persistent storage and convert to relative paths.

- [x] T027 Create `lib/core/storage/migration/media_migrator.dart` to copy files from `tempDir` to `appDocsDir/media/`
- [x] T028 [P] Create `test/core/storage/migration/media_migrator_test.dart` (Tests: persistent source, temp source, missing source, copy failure)
- [x] T029 Integrate `MediaMigrator` into `LegacyPersistenceMigrator` to rescue Daily Report images and verify readable copies
- [x] T030 Update Hive models to store and repositories to resolve **Relative paths** against `appDocsDir`

---

## Phase 6: User Story 3 - Fresh Installation Experience (Priority: P2)

**Goal**: Initialize new database without unnecessary migration for new users.

### Tests for User Story 3
- [x] T031 [US3] Add "Clean Install" tests to `test/core/storage/migration/legacy_persistence_migrator_test.dart`

### Implementation for User Story 3
- [x] T032 [US3] Implement "No Legacy Data" detection to skip migration and set state to `completed` immediately

---

## Phase 7: Daily Report Hive Persistence

**Goal**: Replace Daily Report repository persistence with Hive.

- [x] T033 Create `lib/features/daily_report/data/datasources/daily_report_local_datasource.dart` using Hive
- [x] T034 Update `lib/features/daily_report/data/repository/daily_report_repository_impl.dart` to use `HiveDailyReportLocalDataSource`
- [x] T035 [P] Create `test/features/daily_report/data/datasources/daily_report_local_datasource_test.dart`

---

## Phase 8: Workout Hive Persistence

**Goal**: Replace Workout repository persistence with Hive.

- [x] T036 Update `lib/features/workout/data/datasources/workout_local_datasource.dart` to use Hive (implement `dateKey` logic)
- [x] T037 Update `lib/features/workout/data/repositories/workout_repository_impl.dart` to use new Hive datasource
- [x] T038 [P] Create `test/features/workout/data/datasources/workout_local_datasource_test.dart`
- [x] T039 [US1] Verify Exercise History and Previous Exercise lookup work via Hive record scanning

---

## Phase 9: Settings Persistence (User Story 4)

**Goal**: Move WeightUnit preference to Hive using typed `AppSettingsHiveModel`.

- [x] T040 Implement `lib/core/storage/hive/hive_settings_datasource.dart`
- [x] T041 Update `WorkoutRepositoryImpl.getPreferredUnit()` and `setPreferredUnit()` to use Hive

---

## Phase 10: Startup / DI Switch

**Goal**: Wire up the new persistence layer and migration at app start.

- [x] T042 Update `lib/core/di/injection_container.dart` to register Hive storage, migrator, and new datasources
- [x] T043 Update `lib/main.dart` (or bootstrap file) to initialize Hive and run `LegacyPersistenceMigrator` before repositories are relied upon
- [x] T044 Verify that cutover repositories depend on the successful/skipped migration state

---

## Phase 11: Remove Old Runtime Persistence

**Goal**: Stop writing to SharedPreferences for normal app operations.

- [x] T045 Remove `SharedPreferences` writes from `lib/features/daily_report/data/service/local_data_source.dart`
- [x] T046 Remove `SharedPreferences` writes from `lib/features/workout/data/datasources/workout_local_datasource.dart`
- [x] T047 Retain `SharedPreferences` ONLY for `LegacyPersistenceMigrator` read-only access (for future upgrades)

---

## Phase 12: Regression & Final Verification

- [x] T048 [P] Verify Daily Report History, Edit, and Delete UI work with Hive data
- [x] T049 [P] Verify Workout History UI works with Hive data
- [x] T050 [P] Verify Workout Share Workout / Share Week work with Hive data
- [x] T051 [P] Verify KG/LB toggle persists across restarts via Hive AppSettings
- [x] T052 Perform manual upgrade test: Old build -> Data creation -> Upgrade -> Verify Migration -> Restart
- [x] T053 Run `dart format .`, `flutter analyze`, and `flutter test`

---

## Dependencies & Execution Order

1. **Foundational (Phase 2)**: BLOCKS everything. Models, Adapters, and **Failure UI** must exist first.
2. **Media Rescue (Phase 5)**: BLOCKS migration completion and legacy cleanup.
3. **Legacy Migration (Phase 3-6)**: Must be developed alongside Hive persistence implementation (Phase 7-9).
4. **Startup / DI Switch (Phase 10)**: Depends on all persistence and migration components being ready.
5. **Regression (Phase 12)**: Final step after DI switch.

### Parallel Opportunities
- Models in Phase 2 (T006-T011) can be created in parallel.
- Unit tests for different features (T035, T038) can run in parallel.

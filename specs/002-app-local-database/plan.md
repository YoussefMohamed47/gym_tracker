# Implementation Plan: App-Wide Local Database Migration

**Branch**: `002-app-local-database` | **Date**: 2026-08-19 | **Spec**: [spec.md](file:///D:/gym_tracker/specs/002-app-local-database/spec.md)

## Summary
Migrate structured application persistence from `SharedPreferences` to `Hive CE` to establish a robust, typed source of truth. The migration will use a dedicated `LegacyPersistenceMigrator` to rescue existing history for Daily Reports and Workouts, ensuring failure safety and idempotency. A critical media-rescue strategy is included to move history images from volatile temporary storage to persistent application storage.

## Technical Context

**Language/Version**: Dart 3+, Flutter 3.12+

**Primary Dependencies**: `hive_ce`, `hive_ce_flutter`, `get_it`, `path_provider`

**Storage**: Hive CE (local boxes), Application Documents Directory (for media and relative path root)

**Testing**: `flutter test`, `mocktail` (unit and integration tests for migration and persistence)

**Target Platform**: Android, iOS

**Project Type**: Mobile App

**Performance Goals**: Migration < 2s; sub-100ms repository read/write

**Constraints**: Local-only; no giant JSON in Hive; persistent storage for media; **relative media paths**.

**Scale/Scope**: ~3 discovered legacy domains; ~500 history records avg.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Feature Preservation**: No regressions in Daily Report or History; data compatibility maintained.
- [x] **Architecture**: Follows feature-first (data/domain/presentation) with Bloc/Cubit and GetIt.
- [x] **Local-First**: Hive CE as source of truth for structured data; no unauthorized cloud/API dependencies.
- [x] **Data Integrity**: Stable date identities; user files in persistent storage; KG values canonical.
- [x] **Persistence**: Presentation/Cubit avoid direct Hive access; typed storage used (no giant JSON); schema evolution respected.
- [x] **Migration**: SharedPref-to-Hive is deterministic, idempotent, and failure-safe.
- [x] **UI Identity**: Material 3; #1A46A0 brand color; mobile-optimized layout.
- [x] **Testing**: Business logic, state transitions, and persistence (round-trips/migration) are unit-testable.
- [x] **Simplicity**: No unnecessary packages or over-engineered abstractions.

## Media Rescue Strategy
For every history-critical Daily Report image path discovered in SharedPreferences:
1. **Verification**: Check if the referenced file exists.
2. **Persistence Audit**: Determine if the path is in a durable location (`appDocsDir`).
3. **Rescue**: If in `tempDir/cache`, copy to `appDocsDir/media/` and verify the new file is readable.
4. **Referencing**: Store the **relative path** (from `appDocsDir`) in Hive.
5. **Graceful Failure**: If the file is missing or copy fails, migrate the structured record normally and treat media as unavailable (UI degradation).

## Project Structure

### Documentation (this feature)

```text
specs/002-app-local-database/
├── plan.md              # This file
├── research.md          # Technology choice & inventory
├── data-model.md        # Hive boxes & TypeAdapters
├── quickstart.md        # Validation guide
└── tasks.md             # Implementation tasks
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── storage/
│   │   ├── hive/
│   │   │   ├── hive_registrar.dart
│   │   │   ├── hive_boxes.dart
│   │   │   ├── hive_local_storage.dart
│   │   │   └── models/
│   │   │       ├── app_settings_hive_model.dart (NEW)
│   │   │       └── migration_meta_hive_model.dart (NEW)
│   │   └── migration/
│   │       ├── legacy_persistence_migrator.dart
│   │       ├── media_migrator.dart (NEW)
│   │       └── migration_result.dart
├── features/
│   ├── daily_report/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── daily_report_local_datasource.dart (NEW)
│   │   │   ├── models/
│   │   │   │   └── daily_report_hive_model.dart (NEW)
│   ├── workout/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── workout_local_datasource.dart (UPDATE)
│   │   │   ├── models/
│   │   │   │   ├── workout_session_hive_model.dart (NEW)
│   │   │   │   ├── exercise_log_hive_model.dart (NEW)
│   │   │   │   └── exercise_set_log_hive_model.dart (NEW)

test/
├── core/
│   └── storage/
│       ├── hive/
│       │   └── hive_adapter_test.dart
│       └── migration/
│           ├── legacy_persistence_migrator_test.dart
│           └── media_migrator_test.dart (NEW)
├── features/
│   ├── daily_report/
│   │   └── data/
│   │       └── datasources/
│   │           └── daily_report_local_datasource_test.dart
│   └── workout/
│       └── data/
│           └── datasources/
│               └── workout_local_datasource_test.dart
```

**Structure Decision**: Single project structure with feature-first organization. Hive infrastructure centralized in `core/storage`. Settings and Migration metadata moved to core.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

# Feature Specification: App-Wide Local Database Migration

**Feature Branch**: `002-app-local-database`

**Created**: 2026-08-19

**Status**: Draft

**Input**: User description: "Replace SharedPreferences-based structured application persistence with one app-wide local database architecture (Hive CE). The final local database must become the source of truth for structured mutable application data. Migration must be deterministic, idempotent, failure-safe, and preserve all valid user records without using giant JSON strings in Hive."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Seamless Legacy Migration (Priority: P1)

As an existing user, I want my historical workout data and daily reports to be automatically moved to the new database when I update the app, so that I don't lose any of my progress.

**Why this priority**: Data preservation is the most critical requirement for a persistence migration. Losing user history would be a major failure.

**Independent Test**: Can be tested by seeding `SharedPreferences` with known legacy data (Reports, V1 Workouts, V2 Workouts, Settings) and verifying Hive contains identical data after launch.

**Acceptance Scenarios**:

1. **Given** the app contains valid history in `SharedPreferences`, **When** the app is launched, **Then** all records are migrated to Hive and the migration is marked as complete.
2. **Given** a successful migration, **When** the app is restarted, **Then** the migration logic does not run again and the app reads solely from Hive.
3. **Given** legacy Workout data with both single-weight (V1) and per-set (V2) logs, **When** migrated, **Then** all values (weight, performed status, set logs) are preserved honestly without data fabrication.

---

### User Story 2 - Failure-Safe & Idempotent Retry (Priority: P1)

As a user, I want the migration to be resilient to crashes or interruptions, so that even if something goes wrong mid-process, my data remains safe and eventually migrates correctly.

**Why this priority**: Mobile environments are prone to interruptions (low battery, system kills). A fragile migration could lead to partial data loss or duplicates.

**Independent Test**: Can be tested by simulating a crash (e.g., throwing an error) halfway through migration and verifying that a subsequent launch completes the migration without duplicates.

**Acceptance Scenarios**:

1. **Given** a partial migration was interrupted, **When** the app is launched again, **Then** missing records are migrated and existing Hive records are not duplicated.
2. **Given** a malformed legacy JSON payload for one record, **When** migrating, **Then** other valid records are still migrated and the failure is logged without destroying existing data.

---

### User Story 3 - Fresh Installation Experience (Priority: P2)

As a new user, I want the app to initialize the new database immediately without trying to migrate non-existent legacy data, so that I have a clean and fast startup experience.

**Why this priority**: Ensures the app remains performant and bug-free for new users who don't need migration.

**Independent Test**: Can be tested on a clean device/emulator and verifying Hive initializes but no migration logs or markers are created.

**Acceptance Scenarios**:

1. **Given** no legacy `SharedPreferences` data exists, **When** the app is launched, **Then** Hive is initialized and the migration is marked as skipped/complete immediately.

---

### User Story 4 - Consistent App Settings (Priority: P3)

As a user, I want my application preferences (like weight units) to persist across the migration, so that I don't have to re-configure my settings.

**Why this priority**: Improves user experience by maintaining continuity in preferences.

**Independent Test**: Can be tested by setting WeightUnit to `lb` in legacy storage and verifying Hive reflects `lb` after migration.

**Acceptance Scenarios**:

1. **Given** a preferred weight unit in `SharedPreferences`, **When** migrated, **Then** the preference is available in Hive and respected by the UI.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST detect if a migration is required by checking for recognized legacy `SharedPreferences` keys (`report_history`, `WORKOUT_HISTORY_V1`, `WORKOUT_UNIT_PREFERENCE`) and the absence of a completion marker.
- **FR-002**: The migration process MUST be deterministic and idempotent; multiple runs must result in the same database state without duplicates.
- **FR-003**: The system MUST persist `DailyReport` records as independent, typed Hive objects rather than a single large JSON string.
- **FR-004**: The system MUST persist `WorkoutSession` records as independent, typed Hive objects, maintaining the unique `dateKey` (yyyy-MM-dd) identity.
- **FR-005**: The system MUST preserve legacy `ExerciseLog` data honestly: single-weight (V1) records must not be converted into fake per-set records.
- **FR-006**: The system MUST migrate the `WeightUnit` preference to Hive storage.
- **FR-007**: The system MUST retain file paths and references for images/photos using a robust resolution strategy (e.g., relative paths) to survive application container changes; raw image bytes MUST NOT be stored in Hive.
- **FR-008**: Legacy `SharedPreferences` data MUST NOT be deleted until a full migration has been validated and the completion marker is persisted.
- **FR-009**: In the event of a conflict (data exists in both Hive and stale SharedPreferences), the existing Hive data MUST be preserved (Hive wins).
- **FR-010**: New application writes MUST target the Hive database only; SharedPreferences MUST NOT remain a domain write destination.
- **FR-011**: The system MUST handle malformed records gracefully by skipping them and continuing to migrate other valid records; failures MUST be logged and the corrupted record MUST NOT be marked as successfully migrated.
- **FR-012**: If Hive fails to initialize, the app MUST NOT fall back to SharedPreferences or automatically wipe the database; it MUST surface a deliberate storage-error state with explicit recovery options.
- **FR-013**: The migration MUST move/copy persistent media files found in temporary/cache directories to persistent app storage if possible; failure to recover media MUST NOT block the migration of associated structured records.

## Clarifications

### Session 2026-08-19

- Q: Which data source wins in a logical record identity conflict? → A: Existing Hive data wins; legacy data only inserts missing records.
- Q: How to handle malformed legacy records? → A: Skip affected record, rescue other valid data, and log failure without deleting the legacy source for the failed record.
- Q: When to delete recognized SharedPreferences keys? → A: Only after verified success; if any record fails to migrate (e.g., malformed), the key must be preserved for recovery.
- Q: How to handle file path validation during migration? → A: Validate existence and migrate path; if missing, migrate structured data normally (graceful degradation). Move temp files to persistent storage if possible.
- Q: How to handle Hive initialization/corruption failures? → A: Deliberate failure state with recovery options; no silent fallback to SharedPreferences and no automatic wipes.

### Key Entities *(include if feature involves data)*

- **DailyReport**: Structured record for nutritional and lifestyle tracking (ID, meals, water, sleep, etc.).
- **WorkoutSession**: Aggregate record for a specific date (dateKey, workoutType, exerciseLogs).
- **ExerciseLog**: Record of a specific exercise performed (planned/performed IDs, sets, weight, status, image path).
- **ExerciseSetLog**: Record of an individual set within an exercise (weight, performed status).
- **AppSettings**: Global application preferences (WeightUnit).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of valid legacy records (Reports, Workouts, Settings) from `SharedPreferences` are successfully accessible in the Hive-backed UI after migration.
- **SC-002**: Migration completion for a typical user (1 year of daily history) finishes in under 2 seconds on a mid-range device.
- **SC-003**: Zero duplicate records (Reports or WorkoutSessions) are created in the database even after 5 simulated migration interruptions.
- **SC-004**: Zero data loss for new writes occurring after the migration completion marker is set.

## Assumptions

- **A-001**: The local file system remains the primary storage for media; Hive only needs to store stable relative or absolute paths.
- **A-002**: The existing `dateKey` format (yyyy-MM-dd) for workouts is sufficiently unique for user activity tracking.
- **A-003**: Migration is only required for local structured data; transient UI state does not need to be migrated.
- **A-004**: Users will not manually manipulate `SharedPreferences` values during the migration process.

## Constitution Alignment

- [ ] Feature complies with **Local-First** principle (Hive CE as source of truth).
- [ ] UI/UX follows **Material 3** and **#1A46A0** brand identity.
- [ ] Data handling respects **Data Integrity** and **Structured Persistence** (typed storage, repository abstraction, schema evolution).
- [ ] **Migration** requirements (if applicable) are failure-safe and idempotent.

# Research: App-Wide Local Database Migration (Hive CE)

## Hive CE Technology Decision
- **Chosen**: Hive Community Edition (Hive CE)
- **Rationale**: Approved local database for structured data. High performance, no-boilerplate, and Flutter-friendly.
- **Alternatives Considered**: 
  - SharedPreferences: Currently used, but being deprecated for structured data.
  - SQLite/Drift: Rejected per constitution unless a blocker is found. Hive CE is preferred for simplicity and speed in this context.

## Package Compatibility
Based on current `gym_tracker` dependencies (`flutter_bloc ^9.1.0`, `dart ^3.12.2`):
- `hive_ce`: `^2.2.0`
- `hive_ce_flutter`: `^2.1.0`
- `hive_ce_generator`: `^2.1.0` (dev)
- `build_runner`: `^2.4.12` (dev)

## Current Persistence Inventory

### Legacy SharedPreferences Key Inventory

| Key Name | Feature Owner | Reader/Writer | Payload Format | Target Hive Box | Migration Rule | Cleanup Rule |
|----------|---------------|---------------|----------------|-----------------|----------------|--------------|
| `report_history` | Daily Report | `LocalDataSource` | JSON List of `DailyReport` | `daily_reports` | Convert each JSON entry to `DailyReport` Hive object. | Remove after full migration success. |
| `WORKOUT_HISTORY_V1` | Workout | `WorkoutLocalDataSourceImpl` | JSON Map `{dateKey: SessionJson}` | `workout_sessions` | Convert each map entry to `WorkoutSession` Hive object. | Remove after full migration success. |
| `WORKOUT_UNIT_PREFERENCE` | App Settings | `WorkoutLocalDataSourceImpl` | String (`kg` or `lb`) | `app_settings` | Move to typed `AppSettings` object. | Remove after full migration success. |

## Box Design
| Box Name | Purpose | Value Type | Key Type |
|----------|---------|------------|----------|
| `gym_tracker_daily_reports` | Historical nutritional/lifestyle reports | `DailyReportHiveModel` | `String` (ID) |
| `gym_tracker_workout_sessions` | User workout logs | `WorkoutSessionHiveModel` | `String` (dateKey) |
| `gym_tracker_settings` | App-wide preferences | `AppSettingsHiveModel` | `String` (Key) |
| `gym_tracker_migration_meta` | Migration status and versions | `MigrationMetaHiveModel` | `String` (Key) |

## Domain/Persistence Mapping Strategy
- **Decision**: Dedicated Hive Persistence Models (DTOs) in the data layer.
- **Rationale**: Keep the domain layer pure (zero Flutter/Hive imports) as per constitution. Map to/from domain entities in the repositories.

## Media Path Representation
- **Decision**: **App-managed relative media references**.
- **Rationale**: Storing absolute filesystem paths in the database is fragile in Flutter (especially iOS), as the application container GUID can change during app updates or restores. The app will persist paths relative to the `ApplicationDocumentsDirectory` (for persistent media) or `TemporaryDirectory` (for migration detection). 
- **Implementation**: The data layer will resolve these relative paths against the current environment root before surfacing them to the domain/UI.

## Schema Evolution Strategy
- Use generated `TypeAdapter`s.
- Assign stable `@HiveField(n)` IDs.
- Never reuse field IDs.
- Provide `defaultValue` for new fields.

## Legacy Migration Strategy
- **Component**: `LegacyPersistenceMigrator`
- **Identity Conflict**: **Existing Hive data wins**. Do not overwrite existing Hive data with legacy data.
- **Idempotency**: Use deterministic keys (`reportId`, `dateKey`).
- **Media Migration**: 
    1. Detect files in `tempDir` (Daily Reports).
    2. Copy to durable `appDocsDir/media/`.
    3. Verify integrity of copy.
    4. Persist **relative path** in Hive.
    5. Cleanup temp only after successful Hive record persistence.

## File Persistence Audit
- **Workout Photos**: `getApplicationDocumentsDirectory() / workout_photos/`. **Status**: Persistent. Risk: Low.
- **Daily Report Images**: `getTemporaryDirectory() / daily_report_...`. **Status**: **NOT PERSISTENT**. **Risk**: **CRITICAL**. Migration MUST move these to persistent storage.

## SharedPreferences Removal Strategy
- `shared_preferences` package remains until legacy migration is no longer supported (e.g., several releases).
- All new features and current feature updates must use Hive.
- Repositories will be updated to use `HiveLocalDataSource`.

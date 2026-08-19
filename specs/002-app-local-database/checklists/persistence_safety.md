# Persistence Safety & Migration Checklist: 002-app-local-database

**Purpose**: Strict Technical Peer Reviewer / PR-gate for local database migration to ensure zero data loss and feature parity.
**Created**: 2026-08-19
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)

## I. Migration Safety & Idempotency
*Focus: Preventing duplicates, data loss, and partial failure states.*

- [x] CHK001 - Are deterministic Hive keys (e.g., dateKey, reportId) explicitly required to ensure idempotency during retry? [Clarity, Spec §FR-002, Plan §16]
- [x] CHK002 - Does the specification explicitly prohibit deleting legacy SharedPreferences data before full migration validation? [Completeness, Spec §FR-008, Plan §15]
- [x] CHK003 - Is the "Hive wins" conflict policy (preventing stale legacy data from overwriting new Hive records) clearly defined for all domains? [Consistency, Spec §FR-009, Plan §18]
- [x] CHK004 - Are requirements for marking migration completion (e.g., dedicated Hive metadata) specified to prevent re-runs on fresh installs? [Completeness, Spec §FR-001, Plan §14]
- [x] CHK005 - Does the spec define recovery behavior for malformed legacy JSON that prevents blocking the rest of the valid data migration? [Coverage, Spec §FR-011, Plan §17]

## II. Schema Evolution & Field Stability
*Focus: Hive TypeAdapter field IDs and backwards compatibility.*

- [x] CHK006 - Are stable Hive Field IDs (0, 1, 2...) documented for every persisted field to prevent data corruption during future updates? [Completeness, Data-Model §Persistence Models]
- [x] CHK007 - Does the plan explicitly prohibit the reuse of deleted or changed field IDs? [Consistency, Constitution §VI, Plan §9]
- [x] CHK008 - Are default values specified for all newly introduced optional fields to ensure legacy records load correctly? [Clarity, Plan §9]
- [x] CHK009 - Is the storage format for WorkoutSessions aggregate-based (vs one box per set) to prevent excessive box proliferation? [Clarity, Plan §4, §6]

## III. Infrastructure & Architecture Separation
*Focus: Repository boundaries and dependency isolation.*

- [x] CHK010 - Are repository abstractions defined that hide Hive implementation details (e.g., Boxes, Adapters) from the Cubit/UI? [Architecture, Constitution §II, Plan §3]
- [x] CHK011 - Does the design include dedicated Hive Persistence Models (DTOs) to keep the domain layer pure and free of Hive imports? [Architecture, Plan §10, Research §Domain Mapping]
- [x] CHK012 - Is the initialization sequence (Adapters -> Boxes -> Migration -> DI) explicitly planned to prevent race conditions at startup? [Completeness, Plan §23]
- [x] CHK013 - Are requirements defined for handling Hive initialization/corruption failures (Deliberate Error State vs Silent Fallback)? [Clarity, Spec §FR-012, Plan §17]

## IV. Data Integrity & File Durability
*Focus: Historical accuracy and media preservation.*

- [x] CHK014 - Does the migration strategy include an explicit "Move to Persistent Storage" requirement for images currently stored in temporary/cache directories? [Data Integrity, Spec §FR-013, Research §File Persistence Audit]
- [x] CHK015 - Is the requirement to preserve legacy single-weight Workout records honestly (without fabricating fake set data) clearly specified? [Completeness, Spec §FR-005, Plan §19]
- [x] CHK016 - Are legacy Exercise ID safe-aliases and incorrect historical identities preserved for historical reading? [Consistency, Plan §20]
- [x] CHK017 - Does the specification explicitly prohibit storing raw image bytes inside Hive boxes? [Completeness, Spec §FR-007, Plan §21]

## V. Regression & Feature Parity
*Focus: Ensuring existing features remain functional post-migration.*

- [x] CHK018 - Are regression requirements defined for "Share Workout" and "Share Week" to ensure they consume the new Hive sessions correctly? [Coverage, Spec §Acceptance Scenarios]
- [x] CHK019 - Does the spec mandate parity for WeightUnit (KG/LB) preference persistence across app restarts? [Completeness, Spec §User Story 4]
- [x] CHK020 - Are historical alternative exercise selections included in the workout migration requirements? [Coverage, Spec §Acceptance Scenarios]

## VI. Test Coverage Requirements (Requirements Quality)
*Focus: Ensuring the verification plan covers high-risk areas.*

- [x] CHK021 - Are requirements defined for testing "Interrupted Migration" (simulating crashes) to verify duplicate safety? [Traceability, Spec §User Story 2, Plan §24]
- [x] CHK022 - Does the test plan include "Stale SharedPreferences" conflict scenarios where Hive data already exists? [Coverage, Plan §24]
- [x] CHK023 - Are adapter compatibility tests (new vs old versions) required to verify schema evolution? [Completeness, Plan §24]

## Notes
- CHK014 is a critical gate identified during Research: Daily Report images are currently in temp storage and will be lost if not moved during migration.
- CHK015 ensures historical integrity by preventing the manufacturing of set data from legacy single-weight records.

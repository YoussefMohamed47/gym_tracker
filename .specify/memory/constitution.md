<!--
Sync Impact Report:
- Version change: 1.0.0 -> 1.1.0
- List of modified principles:
  - III. Local-First & Data Integrity (Expanded to prioritize Hive CE)
  - Added: VI. Structured Persistence & Infrastructure
- Added sections: none
- Removed sections: none
- Templates requiring updates:
  - .specify/templates/plan-template.md (✅ updated)
  - .specify/templates/spec-template.md (✅ updated)
  - .specify/templates/tasks-template.md (✅ no changes needed)
- Follow-up TODOs: none
-->

# Gym Tracker Constitution

## Core Principles

### I. Feature Preservation & Compatibility
Existing Daily Report and Report History behavior must continue working. New work must not unnecessarily refactor unrelated working code. Existing saved Daily Report data must remain compatible across application updates.

### II. Feature-First Architecture
Preserve the existing feature-first architecture (data/domain/presentation). Use `flutter_bloc/Cubit` for non-trivial feature state management and `get_it` for dependency injection. Repository interfaces belong at the domain boundary; UI components must not directly own persistence logic.

### III. Local-First & Data Integrity
The application is strictly local-first. Do not introduce backend APIs, Firebase, or cloud synchronization unless explicitly required by a future specification. Hive CE is the approved local database abstraction for structured persistent data. Historical records must never be unintentionally overwritten. Date-based data must use stable normalized calendar identities. Any local file referenced by historical data must use persistent app storage.

### IV. UI/UX Identity (Material 3)
Adhere to Material 3 standards and the #1A46A0 blue brand identity. UI must be responsive, polished, touch-friendly, and optimized for one-handed mobile use. Avoid spreadsheet-like desktop layouts. Reusable visual components should be extracted to improve readability. New UI must feel integrated with the existing app.

### V. Simplicity & Minimal Dependencies
Prefer existing dependencies and avoid over-engineering. Do not introduce unnecessary frameworks or architecture layers. New dependencies require a concrete feature-driven reason and justification.

### VI. Structured Persistence & Infrastructure
Structured application data (Workouts, Reports, Settings) must use typed Hive models and adapters.
- **Abstraction**: Presentation and Cubit code must never directly access Hive boxes; implementation belongs in the data/infrastructure layer.
- **Typed Storage**: Use typed logical aggregate records (e.g., WorkoutSession); do not replace SharedPreferences with giant JSON strings inside Hive.
- **Organization**: Prefer aggregate-based persistence to minimize box proliferation.
- **Static vs. State**: Canonical product catalogs (exercises, schedules) remain source-controlled in code; Hive stores only user/session state.
- **Media**: Store file paths/references only; do not store raw bytes in the database.
- **Migration**: SharedPreferences-to-Hive transitions must be deterministic, idempotent, and failure-safe. Never delete legacy data before successful migration and validation.
- **Schema Evolution**: Hive TypeAdapter field IDs are persistent contracts; never reuse or change them casually. Maintain backwards compatibility.

## Quality & Testing Standards

Business rules, date handling, persistence, conversions, and history behavior must be unit-testable. Important Cubit state transitions should be tested. New features must pass `flutter analyze` and `flutter test` before being considered complete. Persistence logic requires specific testing for initialization, round-trips, and migration idempotency.

## Development Workflow

Feature specifications and this constitution are the authoritative sources of truth. Gemini must not silently add business behavior that is absent from the approved specification. Follow Spec Kit artifacts in order: Specification (WHAT/WHY) -> Plan (HOW) -> Tasks (EXECUTION). Implementation must not deviate from approved artifacts.

## Governance

This constitution supersedes all other informal practices. Amendments require documentation and version increments. All PRs and reviews must verify compliance with these principles.

**Version**: 1.1.0 | **Ratified**: 2026-08-18 | **Last Amended**: 2026-08-19

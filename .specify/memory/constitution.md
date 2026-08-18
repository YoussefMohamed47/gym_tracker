<!--
Sync Impact Report:
- Version change: none -> 1.0.0
- List of modified principles:
  - Added: I. Feature Preservation & Compatibility
  - Added: II. Feature-First Architecture
  - Added: III. Local-First & Data Integrity
  - Added: IV. UI/UX Identity (Material 3)
  - Added: V. Simplicity & Minimal Dependencies
- Added sections: Quality & Testing Standards, Development Workflow
- Removed sections: none
- Templates requiring updates:
  - .specify/templates/plan-template.md (✅ updated)
  - .specify/templates/spec-template.md (✅ updated)
  - .specify/templates/tasks-template.md (✅ updated)
- Follow-up TODOs: none
-->

# Gym Tracker Constitution

## Core Principles

### I. Feature Preservation & Compatibility
Existing Daily Report and Report History behavior must continue working. New work must not unnecessarily refactor unrelated working code. Existing saved Daily Report data must remain compatible across application updates.

### II. Feature-First Architecture
Preserve the existing feature-first architecture (data/domain/presentation). Use `flutter_bloc/Cubit` for non-trivial feature state management and `get_it` for dependency injection. Repository interfaces belong at the domain boundary; UI components must not directly own persistence logic.

### III. Local-First & Data Integrity
The application is strictly local-first. Do not introduce backend APIs, Firebase, or cloud synchronization unless explicitly required by a future specification. Historical records must never be unintentionally overwritten. Date-based data must use stable normalized calendar identities. Any local file referenced by historical data must use persistent app storage.

### IV. UI/UX Identity (Material 3)
Adhere to Material 3 standards and the #1A46A0 blue brand identity. UI must be responsive, polished, touch-friendly, and optimized for one-handed mobile use. Avoid spreadsheet-like desktop layouts. Reusable visual components should be extracted to improve readability. New UI must feel integrated with the existing app.

### V. Simplicity & Minimal Dependencies
Prefer existing dependencies and avoid over-engineering. Do not introduce unnecessary frameworks or architecture layers. New dependencies require a concrete feature-driven reason and justification.

## Quality & Testing Standards

Business rules, date handling, persistence, conversions, and history behavior must be unit-testable. Important Cubit state transitions should be tested. New features must pass `flutter analyze` and `flutter test` before being considered complete.

## Development Workflow

Feature specifications and this constitution are the authoritative sources of truth. Gemini must not silently add business behavior that is absent from the approved specification. Follow Spec Kit artifacts in order: Specification (WHAT/WHY) -> Plan (HOW) -> Tasks (EXECUTION). Implementation must not deviate from approved artifacts.

## Governance

This constitution supersedes all other informal practices. Amendments require documentation and version increments. All PRs and reviews must verify compliance with these principles.

**Version**: 1.0.0 | **Ratified**: 2026-08-18 | **Last Amended**: 2026-08-18

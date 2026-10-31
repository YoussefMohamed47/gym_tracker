# Implementation Plan: Phase 2 (Gamification) & Phase 3 (Advanced Analytics)

**Branch**: `003-phase2-3-analytics-gamification` | **Date**: 2026-10-31 | **Spec**: specs/003-phase2-3-analytics-gamification/spec.md

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

Add Confetti gamification on PRs using `confetti` package in the Workout flow, and add Advanced Analytics (30-Day Volume LineChart, Meal Adherence RadarChart) in the ReportHistoryScreen using `fl_chart`.

## Technical Context

**Language/Version**: Dart 3.5.4, Flutter 3.24.5

**Primary Dependencies**: `flutter_bloc`, `hive_ce`, `confetti`, `fl_chart`, `get_it`

**Storage**: `hive_ce` (Local-First)

**Testing**: `flutter_test`

**Target Platform**: Android/iOS Mobile App

**Project Type**: Mobile Application

**Performance Goals**: 60 fps, fast chart rendering.

**Constraints**: Adhere strictly to existing local-first and feature-first architecture (data/domain/presentation).

**Scale/Scope**: Gamification and Analytics additions to existing Workout and Daily Report features.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Feature Preservation**: No regressions in Daily Report or History; data compatibility maintained.
- [x] **Architecture**: Follows feature-first (data/domain/presentation) with Bloc/Cubit and GetIt.
- [x] **Local-First**: Hive CE as source of truth for structured data; no unauthorized cloud/API dependencies.
- [x] **Data Integrity**: Stable date identities; user files in persistent storage; KG values canonical.
- [x] **Persistence**: Presentation/Cubit avoid direct Hive access; typed storage used (no giant JSON); schema evolution respected.
- [x] **Migration**: SharedPref-to-Hive is deterministic, idempotent, and failure-safe. (N/A for these new calculated views)
- [x] **UI Identity**: Material 3; #1A46A0 brand color; mobile-optimized layout.
- [x] **Testing**: Business logic, state transitions, and persistence (round-trips/migration) are unit-testable.
- [x] **Simplicity**: No unnecessary packages or over-engineered abstractions.

## Project Structure

### Documentation (this feature)

```text
specs/003-phase2-3-analytics-gamification/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/
├── features/
│   ├── workout/
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   └── check_pr_usecase.dart
│   │   │   │   └── get_30_day_volume_usecase.dart
│   │   │   └── models/
│   │   │       └── volume_data_point.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── workout_cubit.dart (modify to check PR)
│   │       └── widgets/
│   │           └── exercise_set_row.dart (add ConfettiWidget)
│   └── daily_report/
│       ├── domain/
│       │   ├── usecases/
│       │   │   └── get_meal_adherence_usecase.dart
│       │   └── models/
│       │       └── meal_adherence_data_point.dart
│       └── presentation/
│           ├── view/
│           │   └── report_history_screen.dart (add Analytics Tab)
│           └── widgets/
│               ├── volume_line_chart.dart (new)
│               └── meal_adherence_radar_chart.dart (new)
```

**Structure Decision**: Extending the existing `workout` and `daily_report` features. Business logic resides in `domain/usecases`. UI state updates via `cubit`, and rendering happens in `presentation/widgets`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (None) | N/A | N/A |

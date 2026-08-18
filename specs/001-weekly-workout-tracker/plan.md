# Implementation Plan: Weekly Workout Tracker

**Branch**: `001-weekly-workout-tracker` | **Date**: 2026-08-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-weekly-workout-tracker/spec.md`

## Summary

Implement a polished weekly workout tracker that digitizes the Sama Fit program. The feature includes weekly navigation, weight recording with KG/LB support, previous-weight prefilling, exercise photos/videos, and curated alternatives.

The technical approach utilizes a feature-first architecture (`lib/features/workout/`) with `flutter_bloc` for state management, `SharedPreferences` for structured data, and `path_provider` for persistent photo storage. Unit conversion logic ensures data integrity by storing a high-precision canonical weight (KG) while providing accurate display values.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.12+ (compatible with SDK ^3.12.2)

**Primary Dependencies**: 
- `flutter_bloc` (v9.1.0)
- `get_it` (v8.0.3)
- `shared_preferences` (v2.5.2)
- `intl` (v0.20.3)
- `path_provider` (v2.1.5)
- `share_plus` (v13.2.0)
- `url_launcher` (proposed: latest stable ~6.3.0)
- `image_picker` (proposed: latest stable ~1.1.0)

**Storage**: `SharedPreferences` for Workout history and settings; App Documents directory for photos. Identities are string-based `dateKey` (`yyyy-MM-dd`).

**Testing**: `flutter_test` with `mocktail` for unit and bloc tests.

**Target Platform**: Mobile (Android/iOS)

**Project Type**: Mobile App

**Performance Goals**: Branded share image generation < 2s; instant unit conversion in UI.

**Constraints**: Local-first (offline capable); Material 3; #1A46A0 brand color.

**Scale/Scope**: ~40 predefined exercises; historical logs for potentially years of use.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Feature Preservation**: No regressions in Daily Report or History; data compatibility maintained. (Using separate storage namespace).
- [x] **Architecture**: Follows feature-first (data/domain/presentation) with Bloc/Cubit and GetIt.
- [x] **Local-First**: No unauthorized cloud/API dependencies; local persistence prioritized.
- [x] **Data Integrity**: Stable date identities; user files in persistent storage.
- [x] **UI Identity**: Material 3; #1A46A0 brand color; mobile-optimized layout.
- [x] **Testing**: Business logic and state transitions are unit-testable.
- [x] **Simplicity**: No unnecessary packages or over-engineered abstractions.

## Project Structure

### Documentation (this feature)

```text
specs/001-weekly-workout-tracker/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Research on alternatives and packages
├── data-model.md        # Detailed entity definitions
├── quickstart.md        # End-to-end validation scenarios
└── checklists/
    └── requirements.md  # Quality checklist
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart  # Registration of new dependencies
│   ├── router/
│   │   └── app_router.dart           # Integration of Workout routes
│   └── utils/
│       └── weight_converter.dart      # Centralized KG/LB logic
├── features/
│   └── workout/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── workout_local_datasource.dart
│       │   ├── models/
│       │   │   ├── workout_session_model.dart
│       │   │   └── exercise_log_model.dart
│       │   └── repositories/
│       │       └── workout_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── workout_session.dart
│       │   │   ├── exercise_log.dart
│       │   │   └── workout_type.dart
│       │   ├── repositories/
│       │   │   └── workout_repository.dart
│       │   └── usecases/
│       │       ├── get_workout_for_date.dart
│       │       ├── save_workout_session.dart
│       │       └── get_previous_exercise_log.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── workout_cubit.dart
│           │   └── workout_state.dart
│           ├── view/
│           │   ├── workout_screen.dart
│           │   └── workout_history_screen.dart
│           └── widgets/
│               ├── workout_week_header.dart
│               ├── exercise_log_card.dart
│               └── share/
│                   └── workout_share_card.dart
```

**Structure Decision**: Option 1: Single project (DEFAULT). Adhering to existing feature-first patterns.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*(No violations detected)*

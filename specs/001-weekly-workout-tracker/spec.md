# Feature Specification: Weekly Workout Tracker

**Feature Branch**: `001-weekly-workout-tracker`

**Created**: 2026-08-18

**Status**: Draft

**Input**: User description: "Build a polished weekly workout tracking feature..."

## Clarifications

### Session 2026-08-18

- Q: If a user selects an alternative, enters a weight, then switches back to the original and back to the alternative, should the "in-session" alternative weight be preserved? → A: Preserve In-Session Draft. Each exercise's in-session draft value is kept when toggling; on save, only the currently selected performed exercise for that slot is persisted.
- Q: Should weights entered in LB mode be stored with high precision or rounded? → A: High Precision Storage. Weights are stored as high-precision Doubles to ensure identity preservation during unit toggling.
- Q: For exercises that appear in multiple workout types, should prefill be global or workout-specific? → A: Workout-Specific. Prefills are pulled only from the previous performance within the same workout type.
- Q: Should prefilled values be automatically recorded as performed on save? → A: Explicit Only. Prefilled values are suggestions, not proof of performance. An exercise becomes performed when the user edits its value or explicitly marks/confirms it as done. Untouched prefilled exercises must not be recorded as performed. Performance status is independent of weight. On Save, if unconfirmed exercises exist, show a "Review Workout" prompt. "Save Anyway" persists only confirmed/edited entries as performed.
- Q: Should underlying image files be physically deleted when a photo is cleared or a session deleted? → A: Delete File with Record. Physically delete the image file from persistent storage whenever the associated log is cleared or the session is deleted to prevent storage bloat.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Main Workout Flow (Priority: P1)

As a user actively training in the gym, I want to quickly view my planned exercises for the day, record my working weights, and view previous performances so that I can train efficiently without distraction.

**Why this priority**: This is the core MVP loop. Without the ability to see and log a workout, the feature has no value.

**Independent Test**: Can be tested by selecting "Push" (Saturday), entering weights for all 6 exercises, and saving. The session should persist across app restarts.

**Acceptance Scenarios**:

1. **First-ever Push workout**: Given a new user, when they select Saturday (Push), then they see 6 empty exercises ready for logging.
2. **First-ever Pull workout**: Given a new user, when they select Sunday (Pull), then they see 7 empty exercises ready for logging.
3. **Saving workout without photos**: When a user logs weights and saves without attaching photos, then the session is saved successfully.
4. **Saving workout with multiple photos**: When a user attaches photos to multiple exercises and saves, then all photos are linked to that specific dated entry.
5. **Restarting app and restoring data**: When the app is killed and restarted, then all saved workout history and current draft weights remain available.
6. **Opening following week's same workout**: When a user navigates to the next Saturday, then the "Push" workout is loaded and prefilled with last week's values.
7. **Previous values prefilled correctly**: Prefilled values match the *most recent* saved occurrence of that specific exercise in that workout type.
8. **Changing new week's value without modifying old history**: Changing Aug 29's weight does NOT mutate Aug 22's stored weight.
9. **Opening already-saved date**: Navigating back to a date with a saved session loads that session in "edit" mode.
10. **Editing saved workout**: Updating a weight in a historical session and saving updates only that specific date.
11. **Sunday-Saturday week calculation**: The week selector correctly starts on Sunday (Pull) and ends on Saturday (Push).
12. **Navigating year/month boundaries**: Navigation correctly jumps from Aug 31 to Sep 1 without breaking the weekly structure.
13. **Rest-day behavior**: Selecting Tuesday or Friday shows a "Rest Day" message and allows access to the Daily Routine.
14. **KG -> LB conversion**: Switching preference to LB converts 100 kg to ~220.5 lb instantly.
15. **LB -> KG conversion**: Switching back to KG restores the original precision (100 kg).
16. **Multiple unit switches**: 10+ switches between KG and LB result in exactly the same stored primary value.
17. **Saving values while LB is selected**: Entering "100" while in LB mode stores the equivalent KG value as the primary truth.
18. **Sharing workout in KG**: Share image displays "kg" when the active unit is KG.
19. **Sharing workout in LB**: Share image displays "lb" when the active unit is LB.
20. **Sharing an entire week**: Generates a summary image showing all training days and their highlights for the week.
21. **Video URL opening**: Tapping the video icon opens the correct YouTube link in an external browser.
22. **Photo add/view/replace/delete**: User can perform all photo management actions within an exercise card.
23. **Missing photo file**: UI displays a "File not found" state if the image is deleted from the device; app does not crash.
24. **Selecting an alternative**: Tapping "Alternative" shows a list of curated options (e.g., DB Bench for Chest Press).
25. **Alternative session scope**: Selecting an alternative only affects the *current* session; next week defaults back to the original plan. If toggling between planned and alternative within the same session, draft weights for both are preserved until save.
26. **Planned exercise remains known**: The system remembers that "Chest Press" was the original intention even when an alternative was performed. On save, only the performed exercise log is persisted.
27. **Alternative gets its own history**: The "Last Weight" for the alternative is pulled from its own previous performance, not the original exercise.
28. **Original weight not incorrectly copied to replacement**: Prefilling handles the switch; the alternative weight field is blank if no previous performance exists for that alternative.
29. **Switching back to original exercise restores history**: Returning to the original planned exercise restores its specific prefill memory.
30. **Sharing displays replacement clearly**: The share image shows "Planned → Performed" (or similar) when an alternative was used.
31. **No duplicate date session**: Attempting to create a new session for a date that already has one loads the existing one.
32. **Daily Routine video access**: Daily Routine exercises have functional video links.
33. **Daily Routine does not force weight**: Daily Routine exercises can be marked complete/saved without any weight input.
34. **Existing Daily Report still works**: The diet/water/sleep tracking feature remains functional and reachable.
35. **Existing Daily Report history still works**: Historical diet reports are unaffected by the new workout history.

---

### User Story 2 - Weight Unit Support & Conversion (Priority: P1)

As a global user, I want to switch between KG and LB seamlessly so that I can use the equipment available in my current gym while preserving the integrity of my historical data.

**Why this priority**: Essential for usability in different regions. Historical data must remain semantically consistent regardless of display unit.

**Independent Test**: Record a weight in KG (e.g., 100 kg), switch to LB, verify display is ~220 lb, switch back to KG, and verify it is exactly 100 kg again.

**Acceptance Scenarios**:

1. **Given** I have recorded 100 kg for an exercise, **When** I change the global unit to LB, **Then** the display changes to 220.46 lb (approx) while the underlying data remains 100 kg.
2. **Given** I am on the Workout screen, **When** I change the unit selector, **Then** all weights on the current screen update instantly without a page reload.

---

### User Story 3 - Exercise Alternatives (Priority: P2)

As a user in a crowded gym, I want to select curated alternative exercises when a specific machine is unavailable so that I can continue my workout without breaking my flow.

**Why this priority**: Solves a major real-world gym pain point (busy equipment).

**Independent Test**: Select "Chest Press Machine", tap "Alternative", select "Dumbbell Bench Press", and verify the history for the original machine is NOT overwritten by the DB bench history.

**Acceptance Scenarios**:

1. **Given** a planned exercise has curated alternatives, **When** I select an alternative, **Then** the exercise card updates to show the performed exercise name while still indicating the original planned exercise.
2. **Given** I selected an alternative, **When** I save the workout, **Then** the history reflects that "Exercise A" was replaced by "Exercise B".

---

### User Story 4 - Media & References (Priority: P3)

As a user, I want to view demonstration videos for unfamiliar exercises and take reference photos of my setup so that I can ensure proper form and consistent setups.

**Why this priority**: Improves exercise execution quality and setup consistency.

**Independent Test**: Tap the video icon to open the YouTube link in a browser, and use the camera to attach a photo to a specific exercise log.

**Acceptance Scenarios**:

1. **Given** an exercise has a video URL, **When** I tap the video action, **Then** the platform's default browser or YouTube app opens the URL.
2. **Given** I am logging an exercise, **When** I take a photo, **Then** it is attached ONLY to that specific dated entry and does not appear in future workouts automatically.

---

### User Story 5 - Sharing & History (Priority: P3)

As a user, I want to share my workout results and view my progress history so that I can stay motivated and track my long-term improvement.

**Why this priority**: Motivates users and provides proof of work.

**Independent Test**: Save a workout, tap "Share", and verify a branded image is generated with the correct weights and exercise names (including alternatives).

**Acceptance Scenarios**:

1. **Given** I have a saved workout, **When** I tap "Share Workout", **Then** a branded image is generated containing the workout name, date, and exercise list with recorded weights.
2. **Given** I am on the Workout screen, **When** I navigate to a previous week using the calendar selector, **Then** I see my saved weights for that specific date.

### Edge Cases

- **Year/Month Boundaries**: Weekly navigation must correctly handle transitions from Dec 31 to Jan 1 or month ends (e.g., Aug 31 to Sep 1).
- **Missing Photo Files**: If a photo file is deleted from storage outside the app, the UI must show a "placeholder" or "missing" state instead of crashing.
- **Corrupt Unit Toggles**: Repeatedly switching KG -> LB -> KG must not introduce rounding errors into the *stored* primary value.
- **Rest Day Interaction**: Selecting a rest day (Tuesday/Friday) should show a pleasant state and offer access to the "Daily Routine" without an empty workout list feeling like a bug.
- **Manual Date Overwrite**: Prevent creating two independent "Push" sessions for the same calendar date; the second attempt should load the existing one for editing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST follow the weekly schedule: Sun=Pull, Mon=Legs, Tue=Rest, Wed=Upper, Thu=Lower, Fri=Rest, Sat=Push.
- **FR-002**: System MUST use a stable normalized date identity (yyyy-MM-dd) for all workout sessions.
- **FR-003**: System MUST prefill "Today's Weight" from the previous occurrence of the *same* exercise in the *same* planned workout type (Workout-Specific history). Prefilled values are suggestions only.
- **FR-004**: System MUST store weights in a primary unit as high-precision Doubles and convert for display based on user preference without cumulative rounding errors.
- **FR-013**: System MUST track an explicit "performed" status for each exercise in a session. On Save, if unconfirmed exercises exist, a confirmation prompt MUST be shown: "X exercises aren't marked as performed. They'll be saved as skipped."
- **FR-005**: System MUST support one working weight value per exercise per session (decimals allowed).
- **FR-006**: System MUST support curated exercise alternatives that maintain their own specific weight history.
- **FR-007**: System MUST allow attaching exactly one photo per exercise log in a dated session. Clearing a photo or deleting the session MUST physically delete the associated image file from storage.
- **FR-008**: System MUST open exercise video URLs in the platform's default browser or YouTube app.
- **FR-009**: System MUST provide a "Daily Routine" section available every day that does not require weight logging.
- **FR-010**: System MUST generate branded share images for "Share Workout" and "Share Week".
- **FR-011**: System MUST integrate with the top-level navigation (Report vs Workout) using a Material 3 NavigationBar.
- **FR-012**: System MUST preserve existing Daily Report and History functionality.

### Key Entities *(include if feature involves data)*

- **WorkoutSession**: Represents a completed or in-progress workout for a specific date. Key attributes: `date`, `workoutType`, `exerciseLogs`.
- **ExerciseLog**: A specific entry for an exercise within a session. Key attributes: `plannedExerciseId`, `performedExerciseId` (if alternative used), `weight`, `unit`, `imagePath`, `isPerformed`.
- **ExerciseDefinition**: Static definition of an exercise. Key attributes: `id`, `name`, `prescribedSets`, `prescribedReps`, `videoUrl`, `isWeightAllowed`.
- **ExerciseAlternative**: Curated link between two ExerciseDefinitions.
- **UserSettings**: Stores global preferences like `preferredWeightUnit`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can log an entire 6-exercise workout in under 60 seconds (excluding exercise performance time).
- **SC-002**: 100% of weights recorded in LB are converted to KG (and back) with zero loss of precision in the primary stored value.
- **SC-003**: 100% of historical workout data remains accessible and editable when the user navigates to any past date.
- **SC-004**: Zero crashes occur when viewing historical workouts where attached photos have been manually deleted from storage.
- **SC-005**: Branded share images are generated in under 2 seconds on standard mobile devices.

## Assumptions

- **Local-Only**: All data is stored locally via `shared_preferences` or local file storage; no cloud sync is required for V1.
- **Single Weight**: Users only care about their heaviest "working weight" per exercise for V1; set-by-set logging is intentionally excluded.
- **Persistent Storage**: Photos taken by the user are expected to survive app cache cleanups (stored in App Documents, not Cache).
- **Fixed Program**: The Sama Fit program structure (exercises per day) is static; users cannot create their own workout programs or add custom exercises in V1.

## Constitution Alignment

- [x] Feature complies with **Local-First** principle (no unsanctioned APIs).
- [x] UI/UX follows **Material 3** and **#1A46A0** brand identity.
- [x] Data handling respects **Data Integrity** (stable identities, persistent storage).
- [x] Existing features (Daily Report) are preserved and reachable via new NavigationBar.

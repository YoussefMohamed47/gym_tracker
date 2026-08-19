# Feature Specification: Weekly Workout Tracker (EVOLUTION V2)

**Feature Branch**: `001-weekly-workout-tracker`

**Created**: 2026-08-18
**Updated**: 2026-08-19 (Revision V2)

**Status**: Draft

**Input**: Evolution requirements for Daily Routine bug fix, per-set weight tracking, history display, and UI/UX polish.

## Clarifications

### Session 2026-08-18

- Q: If a user selects an alternative, enters a weight, then switches back to the original and back to the alternative, should the "in-session" alternative weight be preserved? → A: Preserve In-Session Draft. Each exercise's in-session draft value is kept when toggling; on save, only the currently selected performed exercise for that slot is persisted.
- Q: Should weights entered in LB mode be stored with high precision or rounded? → A: High Precision Storage. Weights are stored as high-precision Doubles to ensure identity preservation during unit toggling.
- Q: For exercises that appear in multiple workout types, should prefill be global or workout-specific? → A: Workout-Specific. Prefills are pulled only from the previous performance within the same workout type.
- Q: Should prefilled values be automatically recorded as performed on save? → A: Explicit Only. Prefilled values are suggestions, not proof of performance. An exercise becomes performed when the user edits its value or explicitly marks/confirms it as done. Untouched prefilled exercises must not be recorded as performed. Performance status is independent of weight. On Save, if unconfirmed exercises exist, show a "Review Workout" prompt. "Save Anyway" persists only confirmed/edited entries as performed.
- Q: Should underlying image files be physically deleted when a photo is cleared or a session deleted? → A: Delete File with Record. Physically delete the image file from persistent storage whenever the associated log is cleared or the session is deleted to prevent storage bloat.

### Session 2026-08-19 (Revision V2)

- Q: How should we handle legacy history that only has a single weight per exercise? → A: Honesty & Initialization. Display legacy records as "Legacy single-weight record" without fabricating set-level data. When creating a new workout from a legacy previous one, show the old weight as a reference and provide a "Use for all sets" action to initialize today's draft.
- Q: Does every set need a weight? → A: Optional. Weights remain optional; do not force zero values.
- Q: What defines an exercise as "performed" now that we have sets? → A: Partial Completion. An exercise is considered performed for the workout if at least one of its sets is explicitly marked as performed.
- Q: Should the Daily Routine support alternatives or weight logging? → A: No. Daily Routine remains fixed (no alternatives) and generally non-weight (no weight inputs by default), but must respect set completion.
- Q: How do we handle history lookup for alternatives? → A: Performed-Exercise History. History (and prefill) is always tied to the *performed* exercise ID within the same `WorkoutType`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Per-Set Workout Flow (Priority: P1)

As a user performing a heavy compound lift, I want to record the specific weight used for EACH set so that I can track my intra-session progression and accurately reflect my training volume.

**Why this priority**: Core evolution for V2. Modern gym trackers must support per-set logging.

**Acceptance Scenarios**:
1. **Entering different weights**: User enters 50kg for Set 1, 52.5kg for Set 2, and 50kg for Set 3. All are saved independently.
2. **Partial completion**: User completes Set 1 and 2 but skips Set 3. Only Set 1 and 2 are recorded as performed.
3. **Set-by-set prefill**: Today's 3-set exercise pulls Set 1, 2, and 3 values from the corresponding set indexes of the *most recent* previous workout of the same type.
4. **Mismatched set counts (Previous < Current)**: Previous workout had 2 sets, current has 3. Set 1 and 2 prefill; Set 3 remains blank.
5. **Mismatched set counts (Previous > Current)**: Previous workout had 4 sets, current has 3. Only Set 1-3 are prefilled; historical Set 4 is ignored for the current session but preserved in history.

### User Story 2 - Exercise History & Reference (Priority: P2)

As a user, I want to see exactly when I last performed an exercise and what my full set history was so that I can make informed decisions about today's load.

**Why this priority**: Contextual awareness is key to progressive overload.

**Acceptance Scenarios**:
1. **Previous Date Display**: The exercise card prominently shows "Previous • Aug 12, 2026" (or the relevant date).
2. **History Bottom Sheet**: Tapping "History" opens a list showing multiple previous sessions (newest first) with their per-set weight breakdowns.
3. **Alternative History**: Selecting "Dumbbell Bench Press" (alternative) loads history for DB Bench Press, not the original "Chest Press Machine".

### User Story 3 - Daily Routine Correctness (Priority: P1)

As a user, I want my Daily Routine to consist of the exact exercises prescribed by the Sama Fit catalog so that I am performing the correct mobility work.

**Why this priority**: Fixes a major V1 bug where "Unknown Exercise" or incorrect placeholders appeared.

**Acceptance Scenarios**:
1. **Data-Driven Routine**: Daily Routine contains exactly: SLR (2 sets), Clam shell (2 sets), neurodynamic sciatic nerve (2 sets), Trunk rotation (2 sets), Double knee to chest (5 sets).
2. **No Placeholders**: No "Joint mobility & dynamic stretching" or "Plank & stability variations" fallbacks appear.
3. **Functional Media**: All 5 routine exercises have working video links.

### User Story 4 - Legacy Data Integrity (Priority: P2)

As a long-term user, I want my historical sessions (logged before per-set tracking) to remain readable and useful without the app fabricating incorrect data.

**Why this priority**: Data safety and trust.

**Acceptance Scenarios**:
1. **Legacy Reading**: Viewing a V1 session shows "Working Weight: 50 kg (Legacy single-weight record)".
2. **Legacy to V2 Transition**: Creating a new workout where the previous session was V1 shows "Previous reference: 50 kg". User can tap "Use for all sets" to populate today's draft sets.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST follow the weekly schedule: Sun=Pull, Mon=Legs, Tue=Rest, Wed=Upper, Thu=Lower, Fri=Rest, Sat=Push.
- **FR-002**: System MUST use a stable normalized date identity (yyyy-MM-dd) for all workout sessions.
- **FR-003**: System MUST prefill per-set values from the corresponding set index of the most recent previous occurrence of the *same* performed exercise in the *same* planned workout type.
- **FR-004**: System MUST store weights in a primary unit as high-precision Doubles (KG) and convert for display based on user preference.
- **FR-005**: System MUST support independent weight values and performed states for EACH prescribed set of an exercise.
- **FR-006**: System MUST support curated exercise alternatives that maintain their own specific set-level weight history.
- **FR-007**: System MUST allow attaching exactly one photo per exercise log.
- **FR-008**: System MUST open exercise video URLs externally.
- **FR-009**: System MUST provide a "Daily Routine" containing EXACTLY 5 exercises (SLR, Clam shell, neurodynamic sciatic nerve, Trunk rotation, Double knee to chest) with prescribed sets and video URLs.
- **FR-010**: System MUST generate share images (Workout/Week) reflecting performed set values.
- **FR-011**: Material 3 UI with compact workout header, 7-day week selector, and polished exercise cards.
- **FR-012**: System MUST preserve existing Daily Report (diet/water/sleep) functionality.
- **FR-013**: System MUST track an explicit "performed" status for each SET. An exercise is performed if at least one set is performed. Save confirmation handles unperformed sets.
- **FR-014**: System MUST provide an "Exercise History" view showing previous performance dates and set-level weights.
- **FR-015**: Exercise cards MUST prominently display the date of the previous workout from which prefill values were sourced.
- **FR-016**: System MUST handle legacy (V1) single-weight records by displaying them as such and allowing them to initialize today's sets via a manual action.

### Key Entities *(updated for V2)*

- **WorkoutSession**: `dateKey`, `workoutType`, `exerciseLogs`, `displayUnit`.
- **ExerciseLog**:
    - `plannedExerciseId`: String
    - `performedExerciseId`: String
    - `sets`: List<ExerciseSetLog>
    - `imagePath`: String?
    - `timestamp`: DateTime
- **ExerciseSetLog**:
    - `weightKg`: double?
    - `isPerformed`: bool

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can log a multi-set exercise with varying weights in under 15 seconds.
- **SC-006**: 100% of legacy V1 data is preserved and readable alongside new V2 data.
- **SC-007**: Daily Routine exercises exactly match the canonical catalog 100% of the time.

## Assumptions

- **Local-Only**: No cloud sync required for V2.
- **Evolutionary Schema**: The `SharedPreferences` key may stay the same, but the internal JSON structure for `exerciseLogs` will evolve to support the `sets` array.
- **Static Program**: Exercise prescriptions (sets/reps) remain data-driven from the catalog.

## Acceptance Scenarios (Summary of Section S)

1. Correct Daily Routine contains exactly 5 canonical exercises.
2. No canonical Daily Routine item shows "Unknown Exercise".
3. 3-set exercise displays exactly 3 set rows.
4. 2-set exercise displays exactly 2.
5. 4-set exercise displays exactly 4.
6. 5-set Daily Routine exercise displays exactly 5 completion rows.
7. Different weights entered for different sets.
8. Partial set completion.
9. Bodyweight set completed with no weight.
10. Previous set-by-set values load correctly.
11. Previous workout date displays correctly.
12. Different previous values remain mapped to correct set index.
13. Previous workout had fewer sets.
14. Previous workout had more sets.
15. Untouched prefilled set is not performed.
16. Historical session remains unchanged after new save.
17. Exercise History shows multiple dates.
18. Exercise History converts correctly KG/LB.
19. Alternative exercise uses its own set-level history.
20. Alternative switching preserves independent set drafts.
21. Legacy one-weight history still opens.
22. Legacy one-weight value is not fabricated into historical set data.
23. Legacy reference can optionally initialize today's sets.
24. Sharing shows performed per-set values.
25. Skipped sets are not falsely shared as performed.
26. Existing photos remain associated correctly.
27. Existing Daily Report functionality remains unchanged.

---

## Out of Scope (V2)
- Reps logging per set, RPE/RIR, rest timer, automatic progressive overload, charts, 1RM, custom plans, backend sync.

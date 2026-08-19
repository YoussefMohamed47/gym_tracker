# Feature Specification: Weekly Workout Tracker (EVOLUTION V3)

**Feature Branch**: `001-weekly-workout-tracker`

**Created**: 2026-08-18
**Updated**: 2026-08-19 (Revision V3)

**Status**: Draft

**Input**: Evolution requirements for Actual Reps per set, Daily Routine reps, Hive schema evolution, and sharing updates.

## Clarifications

### Session 2026-08-18
*(Detailed V1 clarifications archived in Revision V2 context)*

### Session 2026-08-19 (Revision V2)
*(Detailed V2 clarifications archived in Revision V3 context)*

### Session 2026-08-19 (Revision V3)

- Q: Should Daily Routine exercises support rep tracking? → A: Selective Numeric Reps. Repetition-based movements (SLR, Clam shell, neurodynamic sciatic nerve, Trunk rotation) MUST support `actualReps` per set. Duration-based movements (Double knee to chest) remain completion-only (checkbox) for this revision. No actual-duration tracking.
- Q: Should entering reps auto-mark a set as performed? → A: Yes. Explicitly entering/editing `actualReps` automatically marks the set as performed, consistent with weight entry. Prefilled values do NOT trigger performance state.
- Q: How to handle extra sets when prefilling? → A: Strict Index Matching. If today's prescription has more sets than history, unmatched new sets start blank. Never guess or copy the last available set value.
- Q: What is the validation UX for invalid reps? → A: Inline Validation. Display a clear error for non-positive or non-integer values. Do not silently correct or clear inputs. Invalid values must not be persisted.
- Q: What format should Share Week use? → A: Compact Performance format. Use `weight×reps` (e.g., `52.5kg×10 • 50kg×8`) for Share Week to maintain readability in vertical summaries.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Per-Set Rep Tracking (Priority: P1)

As a user training for hypertrophy, I want to record the EXACT reps performed for every set so that I can ensure I am reaching my target intensity and tracking volume correctly.

**Acceptance Scenarios**:
1. **Different Reps per Set**: User enters 52.5kg × 12, 52.5kg × 10, and 50kg × 8. All saved independently.
2. **Bodyweight Reps**: For bodyweight squats, user enters 15, 15, 12 reps with no weight. Saved as `null kg × 15`.
3. **Daily Routine Reps**: SLR shows 2 sets with numeric rep inputs. Double knee to chest shows 5 sets with completion checkboxes only.
4. **Auto-Performance**: Entering "10" in the reps field of an unperformed set automatically toggles it to "Performed".
5. **Validation**: Entering "-1" or "0" or "10.5" in the reps field displays an inline validation error.
6. **Prefill Consistency**: Today's Set 2 pulls both "50kg" and "10 reps" from last week's Set 2 performance.

### User Story 2 - Comprehensive Progression History (Priority: P2)

As a user reviewing my progress, I want to see both weight and reps in my exercise history so that I can see my strength gains over time.

**Acceptance Scenarios**:
1. **History List**: Exercise History bottom sheet shows `Aug 12: S1 50kg × 10, S2 50kg × 9, S3 47.5kg × 8`.
2. **Legacy Per-Set History**: Sets recorded before V3 load with `actualReps = null`. UI displays them gracefully (e.g., `50 kg` without trailing `× null`).
3. **KG/LB Precision**: Switching to LB converts weight to ~110.2 lb but the rep count remains exactly 10.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001** to **FR-004**: *(Preserved from V2: Schedule, Date Identity, High-Precision KG)*.
- **FR-005**: System MUST support independent weight values, `actualReps` (integer), and performed states for EACH prescribed set.
- **FR-009**: Daily Routine MUST support numeric `actualReps` for repetition movements and completion-only for duration movements.
- **FR-010**: System MUST generate share images (Workout/Week) reflecting both weight and actual reps for performed sets.
- **FR-013**: Explicit "performed" status per set. Editing weight OR reps auto-toggles performed = true.
- **FR-014**: Exercise History MUST display dated set breakdowns including `weight × reps`.
- **FR-017**: **[NEW]** `actualReps` prefill MUST match by set index. Extra prescribed sets remain blank.
- **FR-018**: **[NEW]** Reps input MUST use an integer numeric keyboard and enforce positive integer validation with inline error: "Reps must be greater than 0".

### Key Entities *(updated for V3)*

- **ExerciseSetLog**:
    - `weightKg`: double?
    - `actualReps`: int? (Positive integer only)
    - `isPerformed`: bool

## Persistence & Schema Evolution (Hive CE)

- **Schema Safety**: `actualReps` MUST be added as a NEW field ID to the `ExerciseSetLog` Hive adapter.
- **Compatibility**: Existing records must deserialize successfully with `actualReps` defaulting to `null`.
- **No Fabrication**: Historical V1/V2 records must never have reps guessed or derived from metadata.

## Success Criteria *(mandatory)*

- **SC-001**: Users can log both weight and reps for a 3-set exercise in under 20 seconds.
- **SC-008**: **[NEW]** 100% of V2 set records are preserved and readable with reps shown as unavailable.
- **SC-009**: **[NEW]** 0% chance of invalid (negative/decimal/zero) rep counts being persisted to the database.

## Acceptance Scenarios (V3 Additions)

1. Enter different reps for every set.
2. Save and restart; reps remain.
3. Previous set weight and reps display as `LAST: 50kg × 10`.
4. Reps prefill strictly by matching set index.
5. Prefilled reps do not imply performed.
6. Entering reps marks set as performed.
7. Entering invalid reps (0, -1, 10.5) shows inline error.
8. Bodyweight reps show as `12 reps` in sharing, not `0 kg × 12`.
9. Duration-based Daily Routine (Double knee to chest) remains completion-only.
10. Rep-based Daily Routine (SLR) supports numeric actualReps.
11. Alternative switching preserves both weight and rep drafts independently.
12. Share Week uses compact `52.5kg×10` format.
13. Share Workout displays detailed `S1: 52.5 kg × 10` format.
14. Historical Hive sets (V2) load with `actualReps = null`.
15. Sharing historical V2 workouts displays weight only, avoiding `null` labels.

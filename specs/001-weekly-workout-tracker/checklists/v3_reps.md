# Quality Checklist: Weekly Workout Tracker (V3 Actual Reps)

**Purpose**: "Unit Tests for Requirements" — Validating the quality and completeness of V3 specifications for peer review.
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Created**: 2026-08-19
**Actor/Timing**: Peer Reviewer / PR Gate

## Core Repetition Tracking (V3 Delta)

- [ ] CHK001 - Does the spec define a clear visual and semantic distinction between **Prescribed Reps** (program metadata) and **Actual Reps** (user input)? [Clarity, Spec §1]
- [ ] CHK002 - Are requirements specified for `actualReps` per individual set, independent of other sets in the same exercise? [Completeness, Spec §FR-005]
- [ ] CHK003 - Is the requirement to use an **integer numeric keyboard** for reps specified? [Clarity, Spec §FR-018]
- [ ] CHK004 - Does the spec explicitly define **Positive Integer Validation** (no negative, zero, or decimal values allowed)? [Completeness, Spec §FR-018]
- [ ] CHK005 - Are requirements specified for the **Auto-Performance** trigger when entering or editing reps? [Consistency, Spec §FR-013]
- [ ] CHK006 - Does the spec explicitly define the behavior for **Duration-based exercises**, ensuring they do NOT force rep entry? [Clarity, Spec §FR-009]

## Cumulative Per-Set Logic (V2/V3 Evolution)

- [ ] CHK007 - Are prefill requirements defined for matching both **Weight and Reps** by set index? [Completeness, Spec §FR-017]
- [ ] CHK008 - Does the spec prohibit prefilling today's session with yesterday's performed state (Prefill != Performed)? [Consistency, Spec §Clarifications]
- [ ] CHK009 - Are requirements defined for when the current prescription has **MORE sets** than the previous historical record (extra sets start blank)? [Coverage, Spec §Clarifications]
- [ ] CHK010 - Is the **Workout-Specific History** requirement maintained for both weight and reps (no global history leakage)? [Consistency, Spec §Clarifications]
- [ ] CHK011 - Does the spec ensure that **Exercise Alternatives** maintain isolated drafts for both weight and reps? [Consistency, Scenario 11]

## Persistence & Hive Schema Evolution

- [ ] CHK012 - Is `actualReps` explicitly assigned a **NEW unused Hive Field ID** in the persistence model? [Data Integrity, Spec §Persistence]
- [ ] CHK013 - Does the spec define the successful deserialization of **V2 records** (where `actualReps` is missing) as `null`? [Backwards Compatibility, Spec §Persistence]
- [ ] CHK014 - Does the spec explicitly **PROHIBIT the fabrication** of reps from prescribed ranges for historical data? [Data Integrity, Spec §Persistence]
- [ ] CHK015 - Is the requirement to store weight as high-precision KG at the set level maintained? [Consistency, Spec §FR-004]

## Sharing & History Quality

- [ ] CHK016 - Is the **detailed format** (`S1: 52.5 kg × 10`) explicitly specified for **Share Workout**? [Clarity, Spec §FR-010]
- [ ] CHK017 - Is the **compact format** (`52.5kg×10 • 50kg×8`) explicitly specified for **Share Week**? [Clarity, Spec §FR-010]
- [ ] CHK018 - Does the spec define how to display **Bodyweight Reps** in sharing to avoid `0 kg` labels? [Clarity, Scenario 8]
- [ ] CHK019 - Are requirements specified for **gracefully omitting reps** in historical sharing (avoiding "x null")? [Consistency, Scenario 15]
- [ ] CHK020 - Does the spec ensure that **skipped/untouched sets** are excluded from all performed sharing results? [Coverage, Scenario 18]

## Dual-Input Interaction & Accessibility

- [ ] CHK021 - Is a **logical focus sequence** specified for the dual-input flow (Weight → Reps → Next Set Weight)? [Clarity, Spec §FR-011]
- [ ] CHK022 - Are **clear semantic labels** required for Weight, Actual Reps, and Previous values? [Accessibility, Spec §FR-011]
- [ ] CHK023 - Does the spec require **stable focus** during state rebuilds to prevent keyboard flickering or data loss? [Accessibility, Spec §FR-011]
- [ ] CHK024 - Are **touch target requirements** (min 48x48dp) specified for set completion toggles and input fields? [Accessibility, Gap]
- [ ] CHK025 - Does the spec ensure that set completion status is communicated via **symbols/icons**, not just color? [Accessibility, Spec §FR-011]

## Regression Safety

- [ ] CHK026 - Does the spec explicitly preserve existing **Daily Report** (diet/water/sleep) functionality? [Consistency, Scenario 23]
- [ ] CHK027 - Are requirements specified to ensure existing **exercise photo associations** remain intact after schema evolution? [Consistency, Scenario 21]
- [ ] CHK028 - Is **KG/LB weight isolation** maintained (reps never convert during unit switching)? [Consistency, Scenario 13]

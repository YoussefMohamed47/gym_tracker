# Quality Checklist: Weekly Workout Tracker (V2 Evolution)

**Purpose**: "Unit Tests for Requirements" — Validating the quality and completeness of V2 specifications for peer review.
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Created**: 2026-08-19
**Actor/Timing**: Peer Reviewer / PR Gate

## Requirement Completeness (V2 Evolution)

- [ ] CHK001 - Are the EXACT 5 canonical exercises for the Daily Routine explicitly specified with set counts and video link requirements? [Completeness, Spec §FR-009]
- [ ] CHK002 - Does the spec define the required behavior for canonical IDs that currently produce "Unknown Exercise"? [Gap, Spec §FR-009]
- [ ] CHK003 - Are independent weight requirements specified for EACH prescribed set? [Completeness, Spec §FR-005]
- [ ] CHK004 - Is the "performed" state requirement defined at the SET level? [Completeness, Spec §FR-013]
- [ ] CHK005 - Does the spec define what constitutes a "performed exercise" in the context of partial set completion? [Clarity, Spec §FR-013]
- [ ] CHK006 - Are prefill requirements defined for matching Set N (Today) to Set N (Previous)? [Completeness, Spec §FR-003]
- [ ] CHK007 - Is the display requirement for the "Previous Workout Date" explicitly specified for the exercise card? [Completeness, Spec §FR-015]
- [ ] CHK008 - Are multi-date exercise history requirements documented, including set-level visibility? [Completeness, Spec §FR-014]
- [ ] CHK009 - Are requirements specified for sharing per-set values in both Workout and Week summaries? [Completeness, Spec §FR-010]

## Legacy Compatibility & Migration Safety

- [ ] CHK010 - Is the display behavior for historical "Legacy Single-Weight" sessions explicitly defined? [Clarity, Spec §FR-016]
- [ ] CHK011 - Does the spec prohibit the fabrication of per-set data from legacy exercise-level weights? [Consistency, Spec §FR-016]
- [ ] CHK012 - Are requirements defined for the "Use legacy weight for all sets" manual action? [Completeness, Spec §FR-016]
- [ ] CHK013 - Are requirements specified to prevent duplication or corruption of existing photo/session records during schema evolution? [Data Integrity, Spec §SC-006]
- [ ] CHK014 - Is the "Read-Only" nature of legacy records (vs conversion to V2) clearly documented? [Clarity, Spec §FR-016]
- [ ] CHK015 - Does the spec define behavior for repeated app launches/migration attempts? [Edge Case, Gap]

## Scenario & Edge Case Coverage

- [ ] CHK016 - Are requirements defined for when the Previous workout had FEWER sets than today's prescription? [Coverage, Scenario 13]
- [ ] CHK017 - Are requirements defined for when the Previous workout had MORE sets than today's prescription? [Coverage, Scenario 14]
- [ ] CHK018 - Does the spec define the behavior for "bodyweight/non-weight" sets regarding performance vs weight logging? [Clarity, Scenario 9]
- [ ] CHK019 - Are requirements defined for set-level draft isolation when switching between alternative exercises? [Consistency, Scenario 20]
- [ ] CHK020 - Is the behavior for "Untouched prefilled sets" explicitly specified for the Save flow? [Clarity, Scenario 15]

## UI/UX & Interaction Quality

- [ ] CHK021 - Is the mobile UI hierarchy (Sticky Header, Week Selector, Card Structure) defined with specific visual priority? [Clarity, Spec §FR-011]
- [ ] CHK022 - Are keyboard focus requirements (Next moving to next set) explicitly specified? [Clarity, Spec §FR-011]
- [ ] CHK023 - Are numeric/decimal keyboard type requirements documented for weight inputs? [Clarity, Spec §FR-011]
- [ ] CHK024 - Is the visual distinction between "Prefilled" and "Explicitly Performed" states defined? [Clarity, Scenario 15]
- [ ] CHK025 - Are requirements specified for handling 2, 3, 4, and 5-set exercises without excessive empty spacing? [Coverage, Spec §FR-011]

## Accessibility (Standard)

- [ ] CHK026 - Are semantic label requirements defined for important controls (Save, Share, History, Video)? [Coverage, Gap]
- [ ] CHK027 - Are touch target size requirements (minimum 48x48dp) specified for set toggles and inputs? [Coverage, Gap]
- [ ] CHK028 - Does the spec ensure that "Performed" status is not communicated ONLY through color? [Consistency, FR-011]
- [ ] CHK029 - Are text scaling requirements addressed for exercise cards and set lists? [Coverage, Gap]
- [ ] CHK030 - Is logical focus ordering defined for the multi-set input flow? [Clarity, Spec §FR-011]

## Regression & Consistency

- [ ] CHK031 - Does the spec explicitly preserve existing Daily Report (diet/water/sleep) functionality? [Consistency, Spec §FR-012]
- [ ] CHK032 - Are requirements defined to ensure existing photo-to-exercise associations remain intact? [Consistency, Scenario 26]
- [ ] CHK033 - Is the high-precision KG storage integrity maintained at the set level? [Consistency, Spec §FR-004]

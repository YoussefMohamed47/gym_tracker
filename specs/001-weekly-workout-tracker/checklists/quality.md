# Requirements Quality Checklist: Weekly Workout Tracker

**Purpose**: Validate specification completeness and quality (Unit Tests for English)
**Created**: 2026-08-18
**Feature**: [spec.md](../spec.md)

## UX & Accessibility Requirements Quality

- [ ] CHK001 - Are visual hierarchy requirements defined for the Workout screen (e.g., distinguishing today from the rest of the week)? [Clarity, Spec §Design]
- [ ] CHK002 - Is "one-handed phone use" quantified with specific touch-target minimums or reachability zones? [Measurability, Spec §Design]
- [ ] CHK003 - Are semantic labels and accessibility hints defined for non-text actions (video, photo, unit toggle)? [Completeness, A11y]
- [ ] CHK004 - Does the spec define UI behavior for "large text" system settings? [Coverage, A11y]
- [ ] CHK005 - Are loading and error states defined for asynchronous photo loading? [Completeness]

## Weekly Schedule & Date Integrity

- [ ] CHK006 - Is the Sunday-Saturday week calculation logic explicitly defined for boundary cases (e.g., year-end)? [Clarity, Spec §Edge Cases]
- [ ] CHK007 - Are historical immutability rules explicitly stated for date-based logs? [Consistency, Spec §FR-002]
- [ ] CHK008 - Does the requirement for "normalized date identity" provide a specific format (e.g., yyyy-MM-dd)? [Clarity, Spec §FR-002]

## Weight Logic & Conversion Quality

- [ ] CHK009 - Is the KG/LB conversion factor (`1 kg = 2.20462... lb`) explicitly defined to prevent rounding drift? [Clarity, Plan §Weight Model]
- [ ] CHK010 - Are display rounding requirements (e.g., 2 decimal places) consistent across input and history views? [Consistency]
- [ ] CHK011 - Does the spec explicitly prohibit treating unit changes as physical load changes? [Clarity, Spec §User Story 2]
- [ ] CHK012 - Are prefill requirements isolated per workout type as intended? [Consistency, Spec §FR-003]

## Exercise Alternatives & Identity

- [ ] CHK013 - Are "Planned" and "Performed" exercise ID requirements defined for alternative selections? [Completeness, Spec §FR-006]
- [ ] CHK014 - Is the weight-history isolation for alternatives clearly specified? [Clarity, Spec §User Story 3]
- [ ] CHK015 - Does the spec explicitly prohibit AI-generated replacements? [Constraint, Spec §Out of Scope]
- [ ] CHK016 - Is the "in-session draft preservation" logic clearly defined for exercise toggling? [Clarity, Clarification Q1]

## Photo & Persistence Lifecycle

- [ ] CHK017 - Is the distinction between persistent (user photos) and temporary (share images) storage locations documented? [Completeness, Plan §Persistence]
- [ ] CHK018 - Does the spec define graceful failure behavior when the device disk is full during photo capture? [Gap, Exception Flow]
- [ ] CHK019 - Are photo deletion requirements (physical file removal) explicitly gated for both session deletion and photo clearing? [Clarity, Clarification Q5]
- [ ] CHK020 - Does the spec prohibit copying previous photos to new workout sessions? [Constraint, Spec §User Story 4]

## Sharing & Social Requirements

- [ ] CHK021 - Are the content requirements for the "Share Week" image explicitly detailed (e.g., full exercise list density)? [Completeness, Spec §Sharing]
- [ ] CHK022 - Is the privacy of exercise photos explicitly protected in share-image requirements? [Consistency, Spec §Sharing]
- [ ] CHK023 - Are branded elements (colors, logos) for share images defined with specific references? [Clarity]

## Daily Routine & Regressions

- [ ] CHK024 - Are Daily Routine requirements explicitly isolated from weight-logging constraints? [Consistency, Spec §FR-009]
- [ ] CHK025 - Does the spec verify that existing Daily Report navigation remains discoverable? [Consistency, Spec §FR-011]
- [ ] CHK026 - Are regression-prevention requirements defined for historical Daily Report data? [Completeness, Spec §FR-012]

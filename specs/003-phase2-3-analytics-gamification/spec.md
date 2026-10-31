# Feature Specification: Phase 2 (Gamification) & Phase 3 (Advanced Analytics)

**Feature Branch**: `003-phase2-3-analytics-gamification`

**Created**: 2023-11-20

**Status**: Draft

**Input**: User description: "We need to add Confetti when the user logs a PR (higher weight or more reps than previous log) using the newly added confetti package in the ExerciseSetRow or WorkoutScreen. We also need to update the ReportHistoryScreen (or add a new tab) to render charts using fl_chart. Specifically, we want to show 30-Day Volume (Tonnage) using a LineChart, and a radar chart or similar for meal adherence / consistency."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Confetti on PR (Priority: P1)

As a user, I want to see a confetti animation when I log a Personal Record (PR) so that I feel motivated and rewarded for my progress.

**Why this priority**: Immediate gamification provides high dopamine and retention value.

**Independent Test**: Can be fully tested by logging a set with a higher weight or more reps than a previous session and observing the visual confetti effect.

**Acceptance Scenarios**:

1. **Given** I am in an active workout logging a set, **When** I enter a weight or rep count that exceeds my historical maximum for this exercise, **Then** a confetti animation triggers on the screen upon saving/logging the set.
2. **Given** I am logging a set, **When** the performance does not exceed previous records, **Then** no confetti is shown.

---

### User Story 2 - 30-Day Volume Chart (Priority: P1)

As a user, I want to view a line chart of my 30-day training volume (tonnage) so that I can visualize my workload trends over time.

**Why this priority**: Core advanced analytics feature that provides deep insight into progressive overload.

**Independent Test**: Can be fully tested by navigating to the Report History Screen and verifying that the volume line chart accurately plots tonnage (sets * reps * weight) for the past 30 days.

**Acceptance Scenarios**:

1. **Given** I have completed workouts in the past 30 days, **When** I navigate to the charts tab in the Report History screen, **Then** I see a LineChart displaying my daily total volume.

---

### User Story 3 - Meal Adherence Radar Chart (Priority: P2)

As a user, I want to see a radar chart (or similar visualization) of my meal adherence so that I can understand my nutritional consistency at a glance.

**Why this priority**: Enhances the Daily Report by adding visual analytics for nutrition.

**Independent Test**: Can be tested by navigating to the analytics view and verifying the chart correctly reflects the macro/meal adherence score.

**Acceptance Scenarios**:

1. **Given** I have logged daily reports with nutrition adherence, **When** I view my analytics, **Then** I see a radar chart plotting my consistency across different meal types or days.

### Edge Cases

- What happens when a user logs a PR but the animation is still playing from a previous PR?
- How does the 30-Day Volume chart handle days with zero volume (rest days)? (Should plot as 0 or interpolate).
- What happens if the user has less than 3 data points for a Radar chart?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST determine if a newly logged set is a PR by comparing its weight/reps to historical data for that exercise.
- **FR-002**: System MUST trigger a Confetti animation via the `confetti` package when a PR is detected.
- **FR-003**: System MUST calculate daily volume (tonnage = weight * reps) across all exercises per day for the last 30 days.
- **FR-004**: System MUST render a LineChart using `fl_chart` to display the 30-Day Volume.
- **FR-005**: System MUST calculate meal adherence/consistency from Daily Reports.
- **FR-006**: System MUST render a RadarChart (or bar chart if radar not suitable in `fl_chart` for <3 points) to display meal adherence.

### Key Entities

- **ExerciseSet**: Must be comparable to historical maxes.
- **WorkoutSession / Volume**: Aggregate tonnage per day.
- **DailyReport**: Contains meal adherence boolean/scores.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: PR Confetti displays correctly without dropping frames (jank).
- **SC-002**: 30-Day Volume Chart accurately aggregates data and renders in under 500ms.
- **SC-003**: Meal adherence chart clearly visualizes consistency.

## Assumptions

- We already have access to historical set data in the domain layer to check for PRs.
- `confetti` and `fl_chart` packages are already in `pubspec.yaml` or will be added.
- Tonnage is simply (weight * reps).

## Constitution Alignment

- [x] UI/UX follows Material 3.
- [x] Feature complies with Local-First principle (Hive CE).

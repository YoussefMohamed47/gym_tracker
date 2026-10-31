# Phase 1: Data Model

## Confetti / PR Feature
No new persistent entities needed.
We rely on existing `ExerciseSet` or `WorkoutSession` entities.
We may introduce a transient `PRState` or boolean `isPR` flag in the state emitted by the `WorkoutCubit`.

## 30-Day Volume Analytics
- **VolumeDataPoint (Domain Model)**
  - `date`: `DateTime`
  - `tonnage`: `double`

- **VolumeTonnageReport (Domain Model)**
  - `points`: `List<VolumeDataPoint>`
  - `totalTonnage30Days`: `double`

## Meal Adherence Analytics
- **MealAdherenceDataPoint (Domain Model)**
  - `mealType`: `String` (e.g., "Breakfast", "Lunch", "Dinner", "Snacks")
  - `adherenceScore`: `double` (0.0 to 1.0 or percentage based on historical reports)

No new Hive models needed, as these metrics are derived dynamically from existing `DailyReport` and `WorkoutSession` records.

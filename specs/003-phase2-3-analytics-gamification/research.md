# Phase 0: Research

## Confetti Implementation
- **Decision**: Trigger `confetti` animation using a `ConfettiController` stored in the State of the widget (e.g., `ExerciseSetRow` or `WorkoutScreen`). The check for PR will happen in the Bloc/Cubit layer when a set is saved, and if the Cubit yields a "PR achieved" state or event, the UI will call `.play()` on the `ConfettiController`.
- **Rationale**: Keeps business logic out of the UI, aligns with Bloc principles.
- **Alternatives considered**: Triggering it directly from UI logic (rejected because UI shouldn't know historical PR logic).

## Volume Calculation (Tonnage)
- **Decision**: Introduce a domain service/use case `Get30DayVolumeTonnageUseCase` which queries `WorkoutRepository`. It computes the sum of (weight * reps) across all completed sets for each of the past 30 calendar days. 
- **Rationale**: Tonnage calculation is a business rule and belongs in the domain layer.
- **Alternatives considered**: Doing calculation in the data layer (rejected because repository should just return entities, domain applies business logic). Doing it in the UI (violates architecture).

## Line Chart for 30-Day Volume
- **Decision**: Use `fl_chart`'s `LineChart`. The X-axis will represent days (0 to 30), and Y-axis will be the tonnage.
- **Rationale**: Standard choice for time-series continuous data.

## Meal Adherence Chart
- **Decision**: Use `fl_chart`'s `RadarChart` if there are 3 or more meal types/metrics to track. If only 2 metrics (e.g., adhered vs not adhered), fallback to `BarChart`. Our `DailyReport` structure likely supports multiple meals (Breakfast, Lunch, Dinner, Snacks), so `RadarChart` mapping to each meal type's adherence average is appropriate.
- **Rationale**: Radar chart is explicitly requested and provides a nice gamified view of consistency across different vectors.

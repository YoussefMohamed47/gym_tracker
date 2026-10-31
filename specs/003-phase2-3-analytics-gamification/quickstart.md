# Phase 1: Quickstart Validation Guide

## Run UI Gamification Test
1. Compile and run the app.
2. Go to the active workout session screen.
3. Add a new set for any exercise. Enter a weight/rep combination lower than historical max. Save. -> Confirm NO confetti.
4. Add another set for the same exercise. Enter a weight/rep combination explicitly higher than historical max. Save. -> Confirm CONFETTI animation plays.

## Run 30-Day Volume Test
1. Log several workouts spanning across multiple days.
2. Go to Report History Screen -> Charts Tab (or designated Analytics view).
3. Observe the `LineChart`. Verify the X-axis aligns with the dates and Y-axis aligns with the computed tonnage (sum of weight*reps for each day).

## Run Meal Adherence Test
1. Log several Daily Reports across multiple days, checking different adherence values for Breakfast, Lunch, Dinner.
2. View the Analytics Radar Chart.
3. Verify the shape of the radar correctly maps to the average adherence score per meal type.

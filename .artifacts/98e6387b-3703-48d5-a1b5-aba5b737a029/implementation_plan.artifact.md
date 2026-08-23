# Dynamic Workout Type Selection & Training History Logic

Address the issue where missed workouts shift the schedule, requiring a way to manually select what to train "today" while ensuring history tracking follows the training type (e.g., Push) rather than the calendar day.

## User Review Required

> [!IMPORTANT]
> The "Previous Training" logic is already training-type based in your repository. Moving a workout to a different day will **not** break your history tracking. The UI, however, is currently locked to the calendar day.

## Proposed Changes

### Workout Feature

#### [MODIFY] [workout_cubit.dart](file:///E:/Gamer/Courses/Flutter/Projects/gym_tracker_report/lib/features/workout/presentation/cubit/workout_cubit.dart)
- Add `changeWorkoutType(WorkoutType type)` method.
- This method will:
    1. Update the `workoutType` in the state.
    2. Clear current `exerciseLogs` (unless it's an existing session being edited).
    3. Re-initialize logs from `WorkoutCatalog` for the selected type.
    4. Trigger `getPreviousExerciseLog` for each new exercise to pull correct history.

#### [MODIFY] [workout_screen.dart](file:///E:/Gamer/Courses/Flutter/Projects/gym_tracker_report/lib/features/workout/presentation/pages/workout_screen.dart) (I need to find this file path)
- Add a selection mechanism (e.g., `IconButton` or tapping the title) to show a `SimpleDialog` or `ModalBottomSheet` with all available `WorkoutType`s.
- This allows the user to say "Today is Sunday, but I am doing Push".

#### [MODIFY] [workout_catalog.dart](file:///E:/Gamer/Courses/Flutter/Projects/gym_tracker_report/lib/features/workout/data/datasources/workout_catalog.dart)
- Ensure a helper `getWorkoutByType(WorkoutType type)` exists to avoid redundant logic.

## Verification Plan

### Automated Tests
- Unit test for `WorkoutCubit`: Verify that calling `changeWorkoutType` updates the state with the correct exercises and fetches history for those exercises.

### Manual Verification
1. Open the app on a "Rest" day (e.g., Friday).
2. Tap the workout title.
3. Select "Push".
4. Verify that Push exercises appear and show history from the *last time* you did Push.
5. Save the workout and verify it's recorded for "Friday" as a "Push" workout in History.

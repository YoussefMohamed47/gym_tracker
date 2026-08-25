# Enhancement: Scrollable Header for Workout Screen

The current layout uses a static header (`WorkoutHeader` and `WeekDaySelector`) within a `Column`. This restricts the scrollable area of `WorkoutContent` when the keyboard is visible, especially on smaller devices.

## Proposed Changes

We will refactor `WorkoutScreen` and `WorkoutContent` to use a `CustomScrollView` with slivers. This allows the header to scroll away naturally as the user scrolls through exercises or when the keyboard reduces available screen height.

### [Presentation] [Workout Screen](file:///D:/gym_tracker/lib/features/workout/presentation/view/workout_screen.dart)

#### [MODIFY] [workout_screen.dart](file:///D:/gym_tracker/lib/features/workout/presentation/view/workout_screen.dart)
- Replace `Column` with a `CustomScrollView`.
- Wrap `WorkoutHeader` and `WeekDaySelector` in `SliverToBoxAdapter`s.
- Integrate `WorkoutContent` as a collection of slivers instead of an `Expanded` widget.

### [Presentation] [Workout Content](file:///D:/gym_tracker/lib/features/workout/presentation/widgets/workout_content.dart)

#### [MODIFY] [workout_content.dart](file:///D:/gym_tracker/lib/features/workout/presentation/widgets/workout_content.dart)
- Add a new method `toSlivers()` (or similar) that returns a `List<Widget>` of slivers.
- Alternatively, refactor the `build` method to return a `List<Widget>` of slivers if we decide to use it exclusively in `CustomScrollView`.
- Ensure `DailyRoutineSection` and the rest/exercise lists are sliver-compatible.

## Verification Plan

### Automated Tests
- Run existing workout tests to ensure no regressions in logic or state management.
- `flutter test`

### Manual Verification
- Open the Workout Screen.
- Tap a text field (e.g., weight/reps) to open the keyboard.
- Verify that the header scrolls away, allowing more visibility for the exercise cards.
- Verify the Telegram-style theme transition still works when the header is visible.
- Verify the `WorkoutStickySaveBar` remains pinned at the bottom.

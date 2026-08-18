# Quickstart Validation: Weekly Workout Tracker

This guide defines end-to-end validation scenarios to verify the feature works as specified.

## Prerequisites
- Flutter Environment (SDK ^3.12.2)
- Android/iOS Emulator or Device
- Dependencies installed: `flutter pub get`

## Scenario 1: First Workout Log (MVP)
**Goal**: Verify a user can log and save their first workout.
1. Open the app and navigate to the **Workout** tab.
2. Select today's workout (e.g., Saturday - Push).
3. Enter weights for the first two exercises.
4. Tap the **Save Workout** button.
5. **Success Criteria**:
   - Navigation bar shows a checkmark/indicator for today.
   - Restarting the app loads the entered weights for today's date.

## Scenario 2: Prefill Logic
**Goal**: Verify previous values are prefilled in the following week.
1. Save a workout for "Push" on Aug 22 with 50kg for "Chest Press".
2. Change the system date or navigate to Aug 29 (Next Saturday).
3. Open the "Push" workout.
4. **Success Criteria**:
   - "Chest Press" shows "Last: 50 kg".
   - "Today" field is prefilled with 50 (or similar based on interaction rules).

## Scenario 3: Unit Conversion Integrity
**Goal**: Verify KG/LB toggling does not corrupt data.
1. Enter `100` while **LB** is selected.
2. Save the workout.
3. Toggle the unit selector to **KG**.
4. **Success Criteria**:
   - Value displays `45.36` (approx).
   - Toggle back to **LB**.
   - Value displays exactly `100`.

## Scenario 4: Exercise Alternatives
**Goal**: Verify alternatives maintain separate history.
1. Open a "Push" workout.
2. For "Chest Press Machine", tap **Alternative** and select **DB Bench Press**.
3. Record `20` kg and save.
4. Navigate to next week's "Push" workout.
5. **Success Criteria**:
   - Default "Chest Press Machine" prefill is still from its last machine performance (not the 20kg DB performance).
   - Selecting "DB Bench Press" alternative pre-fills `20` kg.

## Scenario 5: Branded Sharing
**Goal**: Verify share image generation.
1. Complete a workout with at least 3 exercises.
2. Tap **Share Workout**.
3. **Success Criteria**:
   - Branded image is generated and the platform share sheet appears.
   - Image contains correct weights, dates, and workout name.

## Running Tests
Execute the following commands to verify core logic:
```bash
flutter test lib/features/workout/domain/entities/weight_converter_test.dart
flutter test lib/features/workout/presentation/cubit/workout_cubit_test.dart
```

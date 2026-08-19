# Quickstart Validation: Weekly Workout Tracker (V2)

This guide defines end-to-end validation scenarios to verify the V2 feature (per-set tracking, Daily Routine fix, and history) works as specified.

## Prerequisites
- Flutter Environment (SDK ^3.12.2)
- Android/iOS Emulator or Device
- Dependencies installed: `flutter pub get`

## Scenario 1: Per-Set Logging (P1)
**Goal**: Verify independent set tracking.
1. Open a workout (e.g., Saturday - Push).
2. For the first exercise, enter:
   - Set 1: 50 kg
   - Set 2: 52.5 kg
   - Set 3: 50 kg
3. Mark all sets as **Done**.
4. Tap **Save**.
5. **Success Criteria**:
   - Save confirmation reports "1 exercise performed".
   - Reloading the session shows all 3 distinct weights correctly.

## Scenario 2: Set-Level Prefill & Previous Date
**Goal**: Verify set N prefills from previous set N and the date is visible.
1. Save a "Pull" workout on Aug 12 with:
   - T-Bar Row: S1=50, S2=50, S3=47.5.
2. Navigate to Aug 19 (Next Wednesday).
3. Open "Pull" workout.
4. **Success Criteria**:
   - Exercise card shows "Previous • Aug 12, 2026".
   - Set 1 shows "Last: 50", Set 2: "Last: 50", Set 3: "Last: 47.5".
   - Today's inputs are prefilled with these values.

## Scenario 3: Legacy Data Support
**Goal**: Verify V1 history remains readable.
1. Open a historical session saved in V1 (where only one weight was recorded).
2. **Success Criteria**:
   - Session loads without crashing.
   - Exercise shows "Working Weight: 50 kg (Legacy single-weight record)".
3. Start a new session where the *previous* session was V1.
4. **Success Criteria**:
   - Card shows "Previous reference: 50 kg".
   - Tapping **Use for all sets** populates today's Set 1, 2, and 3 with 50 kg.

## Scenario 4: Daily Routine Correctness
**Goal**: Verify the 5-exercise mobility routine.
1. Select a Rest Day (Tuesday or Friday) or tap **Daily Routine**.
2. **Success Criteria**:
   - List contains exactly: SLR, Clam shell, neurodynamic sciatic nerve, Trunk rotation, Double knee to chest.
   - Zero "Unknown Exercise" entries.
   - Every item has a functional video link.
   - SLR shows exactly 2 sets for completion.
   - Double knee to chest shows exactly 5 sets.

## Scenario 5: Alternative Draft Preservation
**Goal**: Verify switching alternatives doesn't lose set data.
1. Open "Push".
2. Enter weights for "Chest Press Machine".
3. Switch to **DB Bench Press** (Alternative).
4. Enter different weights for DB Bench.
5. Switch back to **Chest Press Machine**.
6. **Success Criteria**:
   - The original "Chest Press Machine" draft weights are still there.
   - Switching again to **DB Bench Press** restores the DB bench weights.

## Scenario 6: Exercise History View
**Goal**: Verify the history bottom sheet.
1. Tap the **History** icon on an exercise card.
2. **Success Criteria**:
   - Bottom sheet opens showing a list of previous dates.
   - Each date shows the per-set breakdown (e.g., "50 | 50 | 47.5 kg").

## Running Validation Tests
Execute the following to verify core evolution logic:
```bash
# Model compatibility
flutter test test/features/workout/data/models/exercise_log_model_test.dart
# Repository prefill mapping
flutter test test/features/workout/domain/repositories/workout_repository_test.dart
# Cubit draft preservation
flutter test test/features/workout/presentation/cubit/workout_cubit_test.dart
```

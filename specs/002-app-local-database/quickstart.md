# Quickstart: Validating Local Database Migration

## Prerequisites
- Flutter SDK installed.
- Physical device or emulator.
- Access to `adb` (for Android) or `xcrun` (for iOS) to inspect local files if needed.

## Setup
1. Switch to branch `002-app-local-database`.
2. Run `flutter pub get`.
3. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate Hive adapters.

## Validation Scenarios

### 1. Fresh Installation
1. Wipe app data or uninstall app.
2. Launch app.
3. **Verify**: App starts normally.
4. **Verify**: Navigation to History or Workout shows empty state (no errors).
5. **Verify**: Saving a new Daily Report or Workout works and persists after restart.

### 2. Legacy Migration (Automated)
1. Install a previous version of the app (or seed `SharedPreferences` manually using a test script).
2. Ensure `SharedPreferences` contains:
   - Several Daily Reports (some with images).
   - Several Workouts (V1 and V2 styles).
   - Weight preference set to `lb`.
3. Launch the new version of the app.
4. **Verify**: Splash screen or initialization logic reports migration progress (if UI present).
5. **Verify**: History screen shows all legacy Daily Reports.
6. **Verify**: Workout screen shows all historical sessions correctly.
7. **Verify**: Weights are correct (legacy V1 weights preserved; V2 sets preserved).
8. **Verify**: Photos are visible (moved from temp storage if applicable).
9. **Verify**: Settings shows `lb` as selected unit.

### 3. Idempotency & Conflict
1. Seed `SharedPreferences` with data.
2. Run migration partially (e.g., kill app mid-process).
3. Restart app.
4. **Verify**: Migration resumes and completes without duplicate records in Hive.
5. **Verify**: Deleting a record in Hive, then re-running a "stale" migration (if forced), does NOT recreate the record (Hive wins policy).

### 4. Failure Recovery
1. Corrupt the Hive database file manually (e.g., write random bytes to the `.hive` file).
2. Launch app.
3. **Verify**: App shows a "Storage Error" screen with "Reset" and "Retry" options.
4. **Verify**: "Retry" attempts to re-open (still fails if file is corrupted).
5. **Verify**: "Reset" wipes Hive and restarts migration from `SharedPreferences` (if they were not yet cleaned).

## Verification Commands
- **Run all tests**: `flutter test`
- **Verify adapter generation**: Check `lib/**/*.g.dart` files exist and contain `TypeAdapter` logic.
- **Inspect Hive files (Android)**: `adb shell ls /data/data/com.example.gym_tracker/app_flutter/` (Look for `.hive` files).

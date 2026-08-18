# Research: Weekly Workout Tracker

## Decision Log

### 1. Exercise Replacement Matrix
**Decision**: Implement a curated data-driven replacement system using movement-pattern matching.

**Rationale**: Users in busy gyms need alternatives that target the same muscle groups without manual searching. Curated alternatives ensure safety and effectiveness.

| Original Exercise | Alternative Exercise | Primary Target | Movement Pattern | Equipment Diff | Video URL |
|-------------------|----------------------|----------------|------------------|----------------|-----------|
| Chest press machine | DB Bench Press | Chest | Horizontal Push | Machine → DB | https://youtu.be/gRvjfajnZlY |
| Incline chest press machine | DB Incline Bench Press | Upper Chest | Incline Push | Machine → DB | https://youtu.be/8iPEnn-ltC8 |
| Shoulder press machine | DB Shoulder Press | Shoulders | Vertical Push | Machine → DB | https://youtu.be/qEwKSRqnuzw |
| T-bar row | Chest Supported DB Row | Back | Horizontal Pull | T-Bar → DB | https://youtu.be/H75im9fAUMc |
| SA iso-lateral lat row | SA DB Row | Back | Horizontal Pull | Machine → DB | https://youtu.be/dFzUjASsWKY |
| Leg extension | Goblet Squat (Quad focus) | Quads | Knee Extension | Machine → DB | https://youtu.be/MeIiGifIkVo |
| Seated leg curl | DB Leg Curl | Hamstrings | Knee Flexion | Machine → DB | https://youtu.be/uV0B9z-FqXw |
| Adduction machine | Banded Adduction | Adductors | Adduction | Machine → Band | https://youtu.be/m9r_3rQ7y4o |

**Note**: Rehabilitation and mobility exercises (e.g., Clam shells, SLR) are excluded from the replacement matrix per Spec V1.

### 2. Dependency Selection
**Decision**: Use `url_launcher: ^6.3.0` and `image_picker: ^1.1.2`.

**Rationale**:
- `url_launcher`: Industry standard for opening YouTube links externally. Version 6.3.0 is stable and compatible with Dart 3.
- `image_picker`: Most reliable way to handle camera capture and gallery selection in Flutter. Handles permissions and platform differences internally.

### 3. Weight Conversion & Precision
**Decision**: Store all weights as high-precision `double` in **KG**.

**Rationale**: 
- **Normalized Truth**: Storing in a single canonical unit (KG) prevents cumulative rounding errors when toggling display units.
- **Conversion Factor**: `1 kg = 2.20462262185 lb`.
- **UI Rounding**: Round to 1 or 2 decimal places in the UI for display, but keep the full double precision in memory and storage.
- **Gym Logic**: While users might enter "100" lb, the system stores `100 / 2.20462...`. When switching back to LB, it returns exactly `100.0`.

### 4. Photo Persistence Strategy
**Decision**: Copy selected images to `getApplicationDocumentsDirectory()` with a structured filename.

**Rationale**:
- `image_picker` returns a temporary path. We must move the file to persistent storage.
- **Filename**: `workout_{date}_{exerciseId}_{timestamp}.jpg`.
- **Reference**: Store the relative path (or full path) in `ExerciseLog`.

## Technical Research Tasks

### Sunday-Start Week Calculation
The `intl` package provides week calculation, but a custom utility for the Sunday-Saturday boundary is required to match the Sama Fit program requirements.
**Logic**: 
- `findSunday(date)`: `date.subtract(Duration(days: date.weekday % 7))`.
- `weekRange`: `findSunday(date)` to `findSunday(date).add(Duration(days: 6))`.

### Duplicate Date Handling
**Decision**: Use `yyyy-MM-dd` as the unique key in the storage map.
**Rationale**: Simplest way to ensure one session per calendar day. Attempting to create a new session for an existing key will trigger "Load/Edit" mode.

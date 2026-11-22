# CLAUDE.md

<!--
Golden Test: "Would removing this rule cause Claude to make mistakes?"
If not — cut it. Don't restate defaults Claude already knows.
-->

---

# Section A — General Engineering Rules

## 1) Architecture & Separation of Concerns (YOU MUST FOLLOW)

- Follow the project's architecture layer boundaries strictly: presentation → domain → data
- Never bypass layers or mix responsibilities
- UI/presentation layer has ZERO business logic — only rendering, interaction, and state observation
- Business logic lives in the domain layer
- Data access (APIs, databases, storage) lives in the data layer
- Do not introduce new abstractions or patterns without justification

## 2) Shared Code (IMPORTANT)

- Any reusable logic, utility, constant, extension, or helper used in 2+ places goes in `core/`
- Check `core/` before creating new shared code — never duplicate across features

## 3) Error Handling

- Errors flow cleanly across layers — never skip layers
- Handle null, empty, loading, and error states explicitly — no silent failures
- Catch errors at the boundary (data layer), not deep inside business logic

## 4) Change Discipline

- Make the smallest change that solves the problem
- Fix root causes, not symptoms
- Don't refactor unrelated code unless explicitly requested
- Never break existing functionality, APIs, flows, or UX unless explicitly instructed
- Read relevant code before modifying it — state assumptions when unclear

## 5) Dependencies

- Don't add new packages without justification
- Any new package must be: latest stable, well-maintained, production-grade

## 6) Security

- Never hardcode secrets, tokens, or credentials
- Never log sensitive information
- Use structured logging (e.g. `logger` package) with levels (debug/info/warn/error) — debug-level
  logs only in debug builds, never shipped to release
- Validate all external and API input
- Proactively flag security risks when spotted

## 7) Testing

- Write tests for domain and data layer logic
- Bug fixes must include a reproducing test
- Tests must be deterministic — no flaky or timing-dependent tests
- One behavior per test case

## 8) Workflow (Mandatory)

- Before creating any new feature → invoke the `/flutter-feature` skill first for scaffolding and
  architecture reference
- New or changed requirement → check `docs/FEATURE_MAP.md` and the existing feature modules for
  related code, then **ask** whether it goes into an existing feature/module or a new one. Never
  decide this silently. Once done, update the related docs (`docs/BUSINESS_REQUIREMENTS.md`,
  `GLOSSARY.md`, ADR, Feature Map row)
- Before marking any task done → run the `/flutter-code-review` skill
- After task approved → use the `@git-expert` agent for branch, commit, and PR output

## 9) Agents — Proactively Suggest (YOU MUST FOLLOW)

You MUST proactively suggest the appropriate agent when the situation matches. Do not wait for the
user to ask.

- `@debugger` — When a bug, crash, error, or unexpected behavior is encountered
- `@code-reviewer` — After `/flutter-code-review` passes, ALWAYS suggest running `@code-reviewer`
  for a deeper independent review before proceeding to PR
- `@test-writer` — When code is changed or added without corresponding tests, or when test coverage
  is missing
- `@git-expert` — When it's time to create a branch, commit, or PR. Also for merge conflicts,
  rebases, or any complex git situation

---

# Section B — Flutter / Dart Specific Rules

<!--
Follow official Dart style guide, Effective Dart, and flutter_lints defaults,
as enforced by the project's analysis_options.yaml at the repo root.
Rules below only cover things that OVERRIDE defaults or encode project decisions.
-->

## 1) State Management

- Use **Cubit/Bloc** for feature and application state — not Riverpod, Provider, or GetX
- Cubits depend ONLY on use cases — never directly on repositories or data sources
- `setState` is allowed ONLY for local UI state (e.g., toggles, form focus) — never for business
  logic
- Keep `setState` scoped to the smallest widget possible to avoid redundant rebuilds up the tree

## 2) Code Generation (Freezed)

> **FIRST THING after clone, pull, branch switch, or `flutter pub get`** — run codegen before
> building, running, testing, or analyzing (generated files are not in git, so the project won't
> compile without them):
> ```
> dart run build_runner build --delete-conflicting-outputs
> ```

- Use **Freezed** for state unions and immutable data/entity classes — it provides `copyWith`, value
  equality (`==`/`hashCode`), `toString`, and exhaustive `.when()`/`.map()` matching, so don't
  hand-write any of those on a `@freezed` class
- After adding or changing any `@freezed` class, run:
  ```
  dart run build_runner build --delete-conflicting-outputs
  ```
  Use `dart run build_runner watch --delete-conflicting-outputs` during active development so
  generated files stay in sync automatically
- Generated `*.freezed.dart` / `*.g.dart` files are gitignored (since 2026-11-18) — never commit or
  force-add them. CI must run codegen before any build/test/analyze step, or those steps will fail
- Keep `freezed`, `freezed_annotation`, and `build_runner` versions pinned together in
  `pubspec.yaml` and upgrade them as a group — don't bump one without the others, and re-run codegen
  after any Flutter/Dart SDK upgrade
- `sealed class` + `switch` is still fine for simple, non-Freezed unions that don't need `copyWith`
  or generated equality (e.g. a two-variant local enum-like type) — Freezed isn't mandatory for
  every union, just the default for state/entity models

## 3) Domain Layer Purity

- Domain layer must have ZERO Flutter imports
- No `package:flutter/...` in any file under `domain/`

## 4) Feature Folder Structure

- `features/{feature_name}/data/`
- `features/{feature_name}/domain/`
- `features/{feature_name}/presentation/`

## 5) Error Handling Contract

- Data layer: catch exceptions and map to typed `Failure` classes
- Domain layer: return `Either<Failure, T>` (dartz) from use cases and repositories
- Presentation layer: map failures to user-friendly messages and UI states

## 6) Dependency Injection

- Use **`get_it`** as the service locator
- Register dependencies in a single `core/di/` setup file
- Cubits, use cases, and repositories are resolved via `get_it`, not instantiated manually

## 7) Build Method Discipline (IMPORTANT)

- Prefer `const` constructors wherever possible
- NEVER create `TextEditingController`, `AnimationController`, `FocusNode`, or other expensive
  objects inside `build()`
- Avoid heavy work inside `build()` methods
- Dispose controllers and focus nodes in `StatefulWidget.dispose()`
- Prefer small, composed widgets to minimize rebuild scope
- Use `BlocBuilder`/`BlocSelector` on the smallest widget that needs the state — never at the top of
  the tree

## Agent skills

### Issue tracker

Issues live in Azure DevOps Boards (`az boards`). See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), applied as work item tags. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

---

# Section C — Soqyaa Driver Project Map (read selectively)

- **Scope:** Flutter Driver app only; Portal coupon/gate/assignment and backend status engine are external.
- **Requirements priority:** latest user stories/ACs (2026-11-03: Data Access Scope, Coupon, Trip Lifecycle & Route, Station Gate; 2026-11-12: Cancel Trip §7, Portal Live Tracking & Actual Route §8; 2026-11-15: Violations & Objections §9 in `docs/BUSINESS_REQUIREMENTS.md`) → BRD v1.2 → `PRD.md`; actual code determines current implementation only.
- **Business requirements (YOU MUST FOLLOW):** before any feature or bug task, read the relevant section of `docs/BUSINESS_REQUIREMENTS.md` and cite its `DREQ-xx`/story AC ids in the plan. Its contradictions (C1–C8) are already resolved there; its open decisions (O1–O12) must be raised with the user, never decided silently.
- **Terms/statuses:** `GLOSSARY.md`; do not rename or renumber `TripStatus` based on chronological order.
- **Story boundaries:** `docs/DRIVER_STORY_IMPACT.md` (which actions are driver vs Portal/backend).
- **Find code fast:** `docs/FEATURE_MAP.md`; only open relevant areas.
- **Architecture:** `PRP.md` and `clean_architecture_guide.md`; DI `lib/core/di/di.dart`, routing `lib/core/routing/`.
- **Auth/network:** `lib/features/auth/`, `lib/core/network/`, `lib/core/helpers/logout_helper.dart`.
- **Trips/status:** `lib/features/deliveries/`, `lib/core/helpers/enums.dart`.
- **Station events:** `lib/features/trip_execution/presentation/services/realtime_station_status_dispatcher.dart`; `lib/core/network/realtime/`.
- **Live/actual GPS:** `lib/features/trip_execution/presentation/tracking/`, `trip_execution/data/repositories/trip_location_repository_impl.dart`.
- **Handover:** `lib/features/trip_execution/presentation/handover/`; backend completion, not mock verification, defines success.
- **Current gaps:** `TECHNICAL_DOCUMENTATION.md` §9; read before changing related workflows.
- **Why decisions:** read relevant ADR in `docs/adr/`; don't fabricate original tech-choice rationale.
- **Critical:** after gate checkout `InDelivery(8)` starts active tracking; manual logout blocked at `AtStation(7)` and `InDelivery(8)`; value 3 is now `ToStation` (driver Start Trip from `Assigned(2)`, ADR-0005; `InProgress` was deleted); OTP **or** QR; keep GPS until successful final Actual Route acknowledgement. Portal Live Tracking (§8) requires driver GPS collection, live send and route upload to stay unchanged; only auto-retry of a pending route upload is new (DREQ-25).
- **Cancellation:** allowed from any status except `Completed`/`Closed`; driver cancels only from `ToStation` (Dashboard card, Trip Details) / `AtStation` (Loading screen) / `InDelivery` (beneficiary route) with a mandatory backend reason, `features/trip_cancellation/`; StartTrip inside the station may return `AtStation` (DREQ-21–24, ADR-0006).
- **Violations:** driver views violations against them/their tanker and objects only to Driver/Tanker ones; new `features/violations/` (DREQ-26–29, ADR-0007); backend contract pending (O18–O22).
- **Open:** missed SignalR events, reassignment, `Completed`/`Delivered` wording, pre-assignment driver location (BRD §30); never silently decide.
- **Efficiency:** task → `docs/BUSINESS_REQUIREMENTS.md` section → Feature Map → required source files → relevant ADR; do not ingest the BRD PDF for routine tasks.

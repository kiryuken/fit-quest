# FitQuest RPG

FitQuest RPG is an offline-first Flutter fitness tracker that turns a structured
weekly routine into deliberately paced RPG progression. It supports complete
Push, Pull, Legs, Conditioning, and Rest days instead of rewarding isolated
button taps.

> FitQuest is a personal gamification tool, not a medical device or a
> substitute for qualified health advice. Adjust volume and intensity to your
> own capacity.

## What is implemented

- Two editable weekly presets: `PPL × 2` and `Legs Once`.
- Exercise → variation → set tracking for reps, duration, distance, load, RPE,
  completion, and stable local IDs.
- Five canonical attributes: Strength (STR), Agility (AGI), Vitality (VIT),
  Senses (SEN), and Intelligence (INT).
- Per-movement mastery, benchmark scores, personal records, scheduled streaks,
  streak shields, daily quests, milestones, skills, and boss encounters.
- Paginated workout history retained in local Hive storage.
- Idempotent workout completion with startup recovery for pending commits.
- Aurora Glass UI targeting Android and Web.
- One-action local data reset with no account or remote backend.

## Progression model

Character level keeps the XP cost curve:

```text
XP(L → L + 1) = round(100 × L^1.4)
```

A completed session must contain at least 50% valid planned sets. Session XP is
derived from effort breadth and set count, capped at 25 workout XP per day.
Daily quests can add at most 5 more XP. Boss rewards are one-time, outside the
daily training cap, and limited to 25% of the current level cost.

Base attributes do not receive arbitrary workout or boss points. All five are
derived from character level using a physiological-ceiling curve:

```text
Stat(L) = 50 − (50 − 10) × e^(-(L − 1) / 26)
```

This gives faster novice adaptation, diminishing returns with experience, and
an asymptotic ceiling of 50. Movement-specific improvement is represented by
mastery and personal records rather than unbounded raw stats.

## Default training structure

The plans model full sessions such as:

- Push: Standard/Wide/Diamond Push Up and Front/Lateral/Rear Shoulder Raise.
- Pull: Standard/Wide/Chin-Up Pull Up, Hanging Core, and four Curl variations.
- Legs: four Squat variations, Calf Raise, and optional Running.
- Conditioning: optional 3 km Running or 20-minute Cycling.
- Rest: preserves scheduled adherence without granting XP.

Future training-day targets can be edited. The current day and past days remain
fixed so history and quest targets are reproducible.

## Tech stack

| Area | Technology |
| --- | --- |
| Application | Flutter and Dart |
| State management | Riverpod |
| Navigation | GoRouter |
| Persistence | Hive |
| UI | Material 3 and a custom Aurora Glass design system |
| Tests | Flutter Test and Integration Test |

## Run locally

Requirements:

- Flutter stable
- Dart SDK `>=3.4.0 <4.0.0`
- Android SDK for Android builds, or a supported browser for Web

```bash
flutter pub get
flutter run
```

Useful targets:

```bash
flutter run -d chrome
flutter build web --release
flutter build apk --debug
```

## Quality checks

```bash
flutter analyze
flutter test --coverage
flutter test integration_test -d <android-device-id>
```

The automated suite covers stat and XP curves, HP safety, daily reward budgets,
scheduled streaks and shields, mastery and benchmarks, weekly plans, quest
idempotency, Hive round-trips, repositories, reset lifecycle, and core workout
UI behavior.

## Project structure

```text
lib/
├── core/       # Design system, routing, enums, catalogs, constants
├── data/       # Hive datasource, models, adapters, repositories
├── domain/     # Pure progression and workout services
├── features/   # Feature-first presentation
├── providers/  # Riverpod application state
├── app.dart
└── main.dart
```

## Data and privacy

FitQuest has no account system, analytics SDK, cloud sync, or remote backend.
Character data, plans, sessions, quests, achievements, skills, bosses, and
settings stay in local Hive boxes. Resetting from Settings permanently removes
that local data.

Schema v2 intentionally performs a one-time reset of incompatible progression
saves so legacy six-stat or per-exercise reward data cannot corrupt the new
five-stat model.

Only this root README is intended as public documentation. Other Markdown and
private context files are excluded by `.gitignore`.

## License

FitQuest RPG uses the
[PolyForm Noncommercial License 1.0.0](LICENSE).

You may use, study, modify, and share the project for personal and other
noncommercial purposes. Commercial use, monetized derivatives, or use for an
anticipated commercial application requires separate written permission.
Redistributed copies must retain the license and required copyright notice.

This is a source-available noncommercial license, not an OSI-approved
open-source license. Third-party dependencies and assets remain governed by
their own licenses.

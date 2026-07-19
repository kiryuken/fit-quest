# FitQuest RPG

Turn real workouts into RPG progression.

FitQuest RPG is an offline-first fitness game built with Flutter. Each workout
earns experience, develops character stats, advances quests, and unlocks
stronger challenges—all inside an Aurora Glass interface.

> FitQuest RPG is under active development. It is a gamified fitness tracker,
> not a medical device or a substitute for professional health advice.

## Highlights

- Create a character with six attributes: Strength, Agility, Endurance,
  Dexterity, Constitution, and Intelligence.
- Track Push Ups, Pull Ups, Running, Jump Rope, and Boxing sessions.
- Record repetitions, sets, duration, and running distance in meters.
- Earn XP, level up, increase max HP, and build workout streaks.
- Complete rotating daily quests for bonus experience.
- Unlock achievements and martial-arts skill paths.
- Challenge progressively stronger bosses with stat and workout requirements.
- Review workout history, character progress, and personal records.
- Keep all gameplay data locally on the device with Hive.
- Use one action in Settings to erase local progress and rebuild a clean state.

## Tech Stack

| Area | Technology |
| --- | --- |
| Application | Flutter and Dart |
| State management | Riverpod |
| Navigation | GoRouter |
| Local persistence | Hive |
| UI | Material 3 with a custom Aurora Glass design system |
| Testing | Flutter Test |

The repository includes platform scaffolding for Android, iOS, and Web.

## Getting Started

### Requirements

- Flutter on the stable channel
- Dart SDK `>=3.4.0 <4.0.0`
- An Android emulator/device, iOS simulator/device, or supported web browser

### Install and run

```bash
flutter pub get
flutter run
```

To select a specific target:

```bash
flutter devices
flutter run -d <device-id>
```

For web development:

```bash
flutter run -d chrome
```

## Quality Checks

Run static analysis and the complete automated test suite before submitting
changes:

```bash
flutter analyze
flutter test
```

The tests cover progression calculations, HP and streak behavior, repositories,
provider lifecycle, data reset, workout tracking, and core widget journeys.

## Project Structure

```text
lib/
├── core/       # Routing, theme, enums, constants, and shared utilities
├── data/       # Hive datasource, models, catalogs, and repositories
├── domain/     # Pure progression, HP, stat, and damage services
├── features/   # Feature-first presentation screens
├── providers/  # Riverpod state and application services
├── app.dart    # Application theme and router host
└── main.dart   # Hive initialization and application entry point

test/
├── core/
├── data/
├── domain/
├── features/
└── providers/
```

## Data and Privacy

FitQuest RPG currently has no account system or remote backend. Character,
workout, quest, achievement, skill, boss, and settings data are stored in local
Hive boxes on the device. Resetting data from Settings permanently removes this
local progress.

## Project Status

The core loop—character creation, workouts, progression, quests, achievements,
skills, bosses, history, and local reset—is implemented. APIs and data models
may still change while the project is in active development.

## License

No open-source license has been declared for this repository. All rights are
reserved unless the project owner grants explicit permission.

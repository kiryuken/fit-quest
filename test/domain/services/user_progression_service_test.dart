import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/utils/level_requirements.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/domain/services/hp_calculator.dart';
import 'package:fitquest_rpg/domain/services/stat_growth_service.dart';
import 'package:fitquest_rpg/domain/services/user_progression_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProgressionService XP and level growth', () {
    test('level-up derives all five exact stats and fully heals', () {
      final now = DateTime(2026, 7, 20, 12);
      final user = _user(totalXp: 90, currentHp: 40);

      final updated = UserProgressionService.gainXp(user, 20, now: now);

      expect(updated.level, 2);
      expect(updated.currentXp, 10);
      for (final stat in StatType.values) {
        expect(
          updated.getStatValue(stat),
          closeTo(StatGrowthService.baseStatAtLevel(stat, 2), 1e-10),
          reason: stat.name,
        );
      }
      expect(updated.maxHp, 180);
      expect(updated.currentHp, 180);
    });

    test('XP without a level-up cannot inflate a base stat', () {
      final now = DateTime(2026, 7, 20, 12);
      final user = _user();

      final updated = UserProgressionService.gainXp(user, 50, now: now);

      expect(updated.level, 1);
      expect(updated.stats, StatGrowthService.indexedStatsAtLevel(1));
    });

    test('multi-level grants land directly on the same curve', () {
      final now = DateTime(2026, 7, 20, 12);
      final updated = UserProgressionService.gainXp(_user(), 3120, now: now);

      expect(updated.level, 6);
      expect(updated.currentXp, 642);
      for (final stat in StatType.values) {
        expect(
          updated.getStatValue(stat),
          closeTo(StatGrowthService.baseStatAtLevel(stat, 6), 1e-10),
        );
      }
    });
  });

  group('UserProgressionService scheduled workout progression', () {
    test('first valid same-day workout starts the streak at one', () {
      final now = DateTime(2026, 7, 20, 18);
      final user = _user(
        createdAt: DateTime(2026, 7, 20, 8),
        lastWorkoutAt: DateTime(2026, 7, 20, 9),
      );

      final result = UserProgressionService.completeWorkout(
        user,
        eventId: 'workout:first',
        requestedXp: 23,
        masteryPoints: const {'push_up': 15},
        personalRecordMovementIds: const [],
        now: now,
        countsForStreak: true,
      );

      expect(result.user.streak, 1);
      expect(result.user.longestStreak, 1);
      expect(result.user.totalWorkoutsCompleted, 1);
      expect(result.user.masteryXp['push_up'], 15);
    });

    test('every seventh scheduled completion earns one shield', () {
      final now = DateTime(2026, 7, 20, 18);
      final user = _user(
        streak: 6,
        longestStreak: 6,
        scheduledCompletions: 6,
        lastStreakWorkoutAt: DateTime(2026, 7, 19, 18),
      );

      final result = _complete(user, now, eventId: 'workout:seven');

      expect(result.user.streak, 7);
      expect(result.user.longestStreak, 7);
      expect(result.user.streakShields, 1);
      expect(result.user.scheduledCompletions, 7);
    });

    test('a shield covers one missed scheduled day', () {
      final user = _user(
        streak: 8,
        streakShields: 1,
        scheduledCompletions: 8,
        lastStreakWorkoutAt: DateTime(2026, 7, 17),
      );

      final result = _complete(
        user,
        DateTime(2026, 7, 20),
        eventId: 'workout:shield',
        missedScheduledDays: 1,
      );

      expect(result.user.streak, 9);
      expect(result.user.streakShields, 0);
    });

    test('more missed days than shields resets the streak', () {
      final user = _user(
        streak: 8,
        streakShields: 1,
        scheduledCompletions: 8,
        lastStreakWorkoutAt: DateTime(2026, 7, 15),
      );

      final result = _complete(
        user,
        DateTime(2026, 7, 20),
        eventId: 'workout:reset',
        missedScheduledDays: 2,
      );

      expect(result.user.streak, 1);
      expect(result.user.streakShields, 0);
    });

    test('optional training grants progress but does not advance streak', () {
      final user = _user(streak: 4, scheduledCompletions: 4);
      final result = UserProgressionService.completeWorkout(
        user,
        eventId: 'workout:optional',
        requestedXp: 20,
        masteryPoints: const {'running': 8},
        personalRecordMovementIds: const [],
        now: DateTime(2026, 7, 20),
        countsForStreak: false,
      );

      expect(result.user.streak, 4);
      expect(result.user.scheduledCompletions, 4);
      expect(result.user.totalWorkoutsCompleted, 1);
    });

    test('replaying one workout event never duplicates mutations', () {
      final now = DateTime(2026, 7, 20);
      final first = _complete(_user(), now, eventId: 'workout:same');
      final replay = _complete(first.user, now, eventId: 'workout:same');

      expect(replay.duplicate, isTrue);
      expect(replay.user.totalXp, first.user.totalXp);
      expect(replay.user.totalWorkoutsCompleted, 1);
      expect(replay.user.masteryXp, first.user.masteryXp);
    });

    test('workout level-up raises max HP and heals before exertion', () {
      final now = DateTime(2026, 7, 20, 18);
      final user = _user(totalXp: 90, currentHp: 20);
      final result = _complete(
        user,
        now,
        eventId: 'workout:level-up',
        requestedXp: 20,
      );

      expect(result.user.level, 2);
      expect(result.user.maxHp, 180);
      expect(result.user.currentHp, 180);
    });
  });

  group('UserProgressionService budgets and boss victories', () {
    test('workout and quest budgets cap character XP at 30 per day', () {
      final now = DateTime(2026, 7, 20);
      final workout = UserProgressionService.awardXp(
        _user(),
        999,
        source: XpAwardSource.workout,
        now: now,
        eventId: 'workout:budget',
      );
      final quest = UserProgressionService.awardXp(
        workout.user,
        999,
        source: XpAwardSource.quest,
        now: now,
        eventId: 'quest:budget',
      );

      expect(workout.xpAwarded, 25);
      expect(quest.xpAwarded, 5);
      expect(quest.user.totalXp, 30);
    });

    test('boss reward is capped, counted once, and gives no raw stat points',
        () {
      final now = DateTime(2026, 7, 20);
      final initial = _user(bossBattlesWon: 2);
      final first = UserProgressionService.completeBossVictory(
        initial,
        bossId: 'training_dummy',
        requestedXp: 100,
        now: now,
      );
      final replay = UserProgressionService.completeBossVictory(
        first.user,
        bossId: 'training_dummy',
        requestedXp: 100,
        now: now,
      );

      expect(first.xpAwarded, 25);
      expect(first.user.bossBattlesWon, 3);
      expect(first.user.stats, StatGrowthService.indexedStatsAtLevel(1));
      expect(replay.duplicate, isTrue);
      expect(replay.user.bossBattlesWon, 3);
    });
  });
}

ProgressionResult _complete(
  UserModel user,
  DateTime now, {
  required String eventId,
  int requestedXp = 20,
  int missedScheduledDays = 0,
}) {
  return UserProgressionService.completeWorkout(
    user,
    eventId: eventId,
    requestedXp: requestedXp,
    masteryPoints: const {'push_up': 10},
    personalRecordMovementIds: const [],
    now: now,
    countsForStreak: true,
    missedScheduledDays: missedScheduledDays,
  );
}

UserModel _user({
  int totalXp = 0,
  int currentHp = 155,
  int streak = 0,
  int longestStreak = 0,
  int streakShields = 0,
  int scheduledCompletions = 0,
  int bossBattlesWon = 0,
  DateTime? createdAt,
  DateTime? lastWorkoutAt,
  DateTime? lastStreakWorkoutAt,
}) {
  final created = createdAt ?? DateTime(2026, 7, 19, 8);
  final level = LevelRequirements.calculateLevel(totalXp);
  final stats = StatGrowthService.indexedStatsAtLevel(level);
  final maxHp = HpCalculator.maxHp(
    stats[StatType.vitality.index]!.round(),
    level,
  );
  return UserModel(
    id: 'user-1',
    name: 'Tester',
    level: level,
    currentXp: totalXp - LevelRequirements.totalXpForLevel(level),
    totalXp: totalXp,
    stats: stats,
    currentHp: currentHp.clamp(0, maxHp),
    maxHp: maxHp,
    streak: streak,
    longestStreak: longestStreak,
    streakShields: streakShields,
    scheduledCompletions: scheduledCompletions,
    bossBattlesWon: bossBattlesWon,
    lastWorkoutAt: lastWorkoutAt,
    lastStreakWorkoutAt: lastStreakWorkoutAt,
    xpBudgetDate: created,
    createdAt: created,
    updatedAt: created,
  );
}

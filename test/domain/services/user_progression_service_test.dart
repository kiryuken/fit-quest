import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/domain/services/user_progression_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProgressionService.completeWorkout', () {
    test('starts the first streak even when character was created today', () {
      final now = DateTime(2026, 7, 19, 18);
      final user = _user(
        lastWorkoutAt: DateTime(2026, 7, 19, 9),
        updatedAt: DateTime(2026, 7, 19, 9),
      );

      final updated = UserProgressionService.completeWorkout(
        user,
        xpGained: 20,
        statGains: const {StatType.strength: 2},
        now: now,
      );

      expect(updated.streak, 1);
      expect(updated.longestStreak, 1);
    });

    test('earns a shield when the new consecutive streak reaches seven', () {
      final now = DateTime(2026, 7, 19, 18);
      final user = _user(
        streak: 6,
        longestStreak: 6,
        lastWorkoutAt: DateTime(2026, 7, 18, 9),
        updatedAt: DateTime(2026, 7, 18, 9),
      );

      final updated = UserProgressionService.completeWorkout(
        user,
        xpGained: 20,
        statGains: const {},
        now: now,
      );

      expect(updated.streak, 7);
      expect(updated.longestStreak, 7);
      expect(updated.streakShields, 1);
    });

    test('recomputes max HP and fully heals on a workout level-up', () {
      final now = DateTime(2026, 7, 19, 18);
      final user = _user(
        level: 1,
        currentXp: 90,
        totalXp: 90,
        currentHp: 20,
        maxHp: 65,
        streak: 1,
        lastWorkoutAt: DateTime(2026, 7, 19, 9),
        updatedAt: DateTime(2026, 7, 19, 9),
      );

      final updated = UserProgressionService.completeWorkout(
        user,
        xpGained: 20,
        statGains: const {},
        now: now,
      );

      expect(updated.level, 2);
      expect(updated.currentXp, 10);
      expect(updated.maxHp, 70);
      expect(updated.currentHp, 70);
    });

    test('updates max HP for Constitution without healing to full', () {
      final now = DateTime(2026, 7, 19, 18);
      final user = _user(
        currentHp: 50,
        maxHp: 65,
        streak: 1,
        lastWorkoutAt: DateTime(2026, 7, 19, 9),
        updatedAt: DateTime(2026, 7, 19, 9),
      );

      final updated = UserProgressionService.completeWorkout(
        user,
        xpGained: 20,
        statGains: const {StatType.constitution: 1},
        now: now,
      );

      expect(updated.maxHp, 75);
      expect(updated.currentHp, 45);
    });
  });

  group('UserProgressionService.completeBossVictory', () {
    test('applies rewards and increments the boss win counter once', () {
      final now = DateTime(2026, 7, 19, 18);
      final user = _user(
        bossBattlesWon: 2,
        currentHp: 10,
        maxHp: 65,
        updatedAt: DateTime(2026, 7, 19, 9),
      );

      final updated = UserProgressionService.completeBossVictory(
        user,
        xpReward: 100,
        statRewards: const {
          StatType.strength: 2,
          StatType.constitution: 2,
        },
        now: now,
      );

      expect(updated.bossBattlesWon, 3);
      expect(updated.totalXp, 100);
      expect(updated.level, 2);
      expect(updated.getStat(StatType.strength), 3);
      expect(updated.getStat(StatType.constitution), 3);
      expect(updated.maxHp, 90);
      expect(updated.currentHp, 90);
    });
  });
}

UserModel _user({
  int level = 1,
  int currentXp = 0,
  int totalXp = 0,
  int currentHp = 65,
  int maxHp = 65,
  int streak = 0,
  int longestStreak = 0,
  int streakShields = 0,
  int bossBattlesWon = 0,
  DateTime? lastWorkoutAt,
  DateTime? updatedAt,
}) {
  final createdAt = DateTime(2026, 7, 19, 8);
  return UserModel(
    id: 'user-1',
    name: 'Tester',
    level: level,
    currentXp: currentXp,
    totalXp: totalXp,
    stats: {
      for (final stat in StatType.values) stat.index: 1,
    },
    currentHp: currentHp,
    maxHp: maxHp,
    streak: streak,
    longestStreak: longestStreak,
    streakShields: streakShields,
    bossBattlesWon: bossBattlesWon,
    lastWorkoutAt: lastWorkoutAt ?? createdAt,
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
  );
}

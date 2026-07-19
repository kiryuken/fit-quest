import '../../core/enums/stat_type.dart';
import '../../core/utils/level_requirements.dart';
import '../../data/models/user_model.dart';
import 'hp_calculator.dart';
import 'stat_growth_service.dart';

/// Pure progression calculations shared by user-state commands.
class UserProgressionService {
  UserProgressionService._();

  static UserModel gainXp(
    UserModel current,
    int amount, {
    required DateTime now,
  }) {
    final newTotalXp = current.totalXp + amount;
    final newLevel = LevelRequirements.calculateLevel(newTotalXp);
    final xpInLevel = newTotalXp - LevelRequirements.totalXpForLevel(newLevel);
    final newStats = _applyLevelGrowth(
      current.stats,
      fromLevel: current.level,
      toLevel: newLevel,
    );

    var updated = current.copyWith(
      totalXp: newTotalXp,
      currentXp: xpInLevel,
      level: newLevel,
      stats: newStats,
      updatedAt: now,
    );

    if (newLevel > current.level) {
      final newConstitution = newStats[StatType.constitution.index] ?? 1;
      final newMaxHp = HpCalculator.maxHp(
        newConstitution,
        newLevel,
      );
      updated = updated.copyWith(
        maxHp: newMaxHp,
        currentHp: newMaxHp,
      );
    }

    return updated;
  }

  static UserModel gainStatXp(
    UserModel current,
    Map<StatType, int> statXp, {
    required DateTime now,
  }) {
    final newStats = _applyStatGains(current.stats, statXp);
    final oldConstitution = current.getStat(StatType.constitution);
    final newConstitution = newStats[StatType.constitution.index] ?? 1;
    final constitutionChanged = newConstitution != oldConstitution;
    final newMaxHp = constitutionChanged
        ? HpCalculator.maxHp(newConstitution, current.level)
        : current.maxHp;

    return current.copyWith(
      stats: newStats,
      maxHp: newMaxHp,
      currentHp: current.currentHp.clamp(0, newMaxHp),
      updatedAt: now,
    );
  }

  static UserModel completeWorkout(
    UserModel current, {
    required int xpGained,
    required Map<StatType, int> statGains,
    required DateTime now,
  }) {
    final newStreak = calculateStreak(
      lastWorkout: current.lastWorkoutAt,
      currentStreak: current.streak,
      now: now,
    );
    final newLongest =
        newStreak > current.longestStreak ? newStreak : current.longestStreak;
    final newShields = calculateShields(
      currentShields: current.streakShields,
      lastWorkout: current.lastWorkoutAt,
      now: now,
      newStreak: newStreak,
    );

    final constitution = current.getStat(StatType.constitution);
    final hpCost = HpCalculator.exertionCost(xpGained, constitution);
    var newHp = current.currentHp - hpCost;

    if (isConsecutiveDay(current.lastWorkoutAt, now)) {
      final regen = HpCalculator.dailyRegen(
        constitution,
        current.getStat(StatType.endurance),
      );
      newHp = HpCalculator.applyRegen(newHp, current.maxHp, regen);
    }

    final statsAfterWorkout = _applyStatGains(current.stats, statGains);
    final newTotalXp = current.totalXp + xpGained;
    final newLevel = LevelRequirements.calculateLevel(newTotalXp);
    final xpInLevel = newTotalXp - LevelRequirements.totalXpForLevel(newLevel);
    final newStats = _applyLevelGrowth(
      statsAfterWorkout,
      fromLevel: current.level,
      toLevel: newLevel,
    );
    final newConstitution = newStats[StatType.constitution.index] ?? 1;
    final maxHpChanged =
        newLevel != current.level || newConstitution != constitution;
    final newMaxHp = maxHpChanged
        ? HpCalculator.maxHp(newConstitution, newLevel)
        : current.maxHp;
    final leveledUp = newLevel > current.level;

    return current.copyWith(
      totalXp: newTotalXp,
      currentXp: xpInLevel,
      level: newLevel,
      stats: newStats,
      streak: newStreak,
      longestStreak: newLongest,
      streakShields: newShields,
      maxHp: newMaxHp,
      currentHp: leveledUp ? newMaxHp : newHp.clamp(0, newMaxHp),
      lastWorkoutAt: now,
      totalWorkoutsCompleted: current.totalWorkoutsCompleted + 1,
      updatedAt: now,
    );
  }

  static UserModel completeBossVictory(
    UserModel current, {
    required int xpReward,
    required Map<StatType, int> statRewards,
    required DateTime now,
  }) {
    final withStats = gainStatXp(current, statRewards, now: now);
    final withXp = gainXp(withStats, xpReward, now: now);
    return withXp.copyWith(
      bossBattlesWon: current.bossBattlesWon + 1,
      updatedAt: now,
    );
  }

  static int calculateStreak({
    required DateTime lastWorkout,
    required int currentStreak,
    required DateTime now,
  }) {
    if (currentStreak <= 0) return 1;
    if (isSameDay(lastWorkout, now)) return currentStreak;
    if (isConsecutiveDay(lastWorkout, now)) return currentStreak + 1;
    return 1;
  }

  static int calculateShields({
    required int currentShields,
    required DateTime lastWorkout,
    required DateTime now,
    required int newStreak,
  }) {
    if (isConsecutiveDay(lastWorkout, now) &&
        newStreak > 0 &&
        newStreak % 7 == 0) {
      return (currentShields + 1).clamp(0, 3);
    }
    return currentShields;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isConsecutiveDay(DateTime a, DateTime b) {
    final difference = DateTime(b.year, b.month, b.day)
        .difference(DateTime(a.year, a.month, a.day));
    return difference.inDays == 1;
  }

  static Map<int, int> _applyLevelGrowth(
    Map<int, int> currentStats, {
    required int fromLevel,
    required int toLevel,
  }) {
    if (toLevel <= fromLevel) return currentStats;

    final gains = <StatType, int>{
      for (final stat in StatType.values)
        stat: StatGrowthService.wholePointGainBetweenLevels(
          stat,
          fromLevel: fromLevel,
          toLevel: toLevel,
        ),
    };
    return _applyStatGains(currentStats, gains);
  }

  static Map<int, int> _applyStatGains(
    Map<int, int> currentStats,
    Map<StatType, int> statGains,
  ) {
    final newStats = Map<int, int>.from(currentStats);
    for (final entry in statGains.entries) {
      final currentValue = newStats[entry.key.index] ?? 1;
      newStats[entry.key.index] = (currentValue + entry.value).clamp(0, 100);
    }
    return newStats;
  }
}

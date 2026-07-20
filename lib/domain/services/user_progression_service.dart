import 'dart:math' as math;

import '../../core/enums/stat_type.dart';
import '../../core/utils/level_requirements.dart';
import '../../data/models/user_model.dart';
import 'hp_calculator.dart';
import 'stat_growth_service.dart';
import 'workout_reward_service.dart';

enum XpAwardSource { workout, quest, boss, system }

class ProgressionResult {
  final UserModel user;
  final int xpAwarded;
  final bool leveledUp;
  final bool duplicate;

  const ProgressionResult({
    required this.user,
    required this.xpAwarded,
    required this.leveledUp,
    this.duplicate = false,
  });
}

/// Pure progression calculations shared by user-state commands.
///
/// Base attributes are always re-derived from [StatGrowthService] at the
/// resulting level. Workout effort can increase character XP and movement
/// mastery, but it cannot add raw base-stat points.
class UserProgressionService {
  UserProgressionService._();

  static ProgressionResult awardXp(
    UserModel current,
    int requestedAmount, {
    required XpAwardSource source,
    required DateTime now,
    String? eventId,
  }) {
    if (requestedAmount < 0) {
      throw RangeError.value(
        requestedAmount,
        'requestedAmount',
        'must not be negative',
      );
    }

    if (eventId != null && current.processedEventXp.containsKey(eventId)) {
      return ProgressionResult(
        user: current,
        xpAwarded: current.processedEventXp[eventId]!,
        leveledUp: false,
        duplicate: true,
      );
    }

    final today = _dateOnly(now);
    final budgetIsCurrent = _isSameDay(current.xpBudgetDate, today);
    final workoutXpToday = budgetIsCurrent ? current.workoutXpToday : 0;
    final questXpToday = budgetIsCurrent ? current.questXpToday : 0;

    final acceptedAmount = switch (source) {
      XpAwardSource.workout => math.min(
          requestedAmount,
          WorkoutRewardService.remainingWorkoutBudget(workoutXpToday),
        ),
      XpAwardSource.quest => math.min(
          requestedAmount,
          WorkoutRewardService.remainingQuestBudget(questXpToday),
        ),
      XpAwardSource.boss => math.min(
          requestedAmount,
          math.max(
            1,
            (LevelRequirements.xpToNextLevel(current.level) * 0.25).round(),
          ),
        ),
      XpAwardSource.system => requestedAmount,
    };

    final newTotalXp = current.totalXp + acceptedAmount;
    final newLevel = LevelRequirements.calculateLevel(newTotalXp);
    final leveledUp = newLevel > current.level;
    final exactStats = StatGrowthService.indexedStatsAtLevel(newLevel);
    final vitality = exactStats[StatType.vitality.index]!.round();
    final newMaxHp = HpCalculator.maxHp(vitality, newLevel);
    final processedEvents = Map<String, int>.from(current.processedEventXp);
    if (eventId != null) processedEvents[eventId] = acceptedAmount;

    final updated = current.copyWith(
      totalXp: newTotalXp,
      currentXp: newTotalXp - LevelRequirements.totalXpForLevel(newLevel),
      level: newLevel,
      stats: exactStats,
      maxHp: newMaxHp,
      currentHp: leveledUp ? newMaxHp : current.currentHp.clamp(0, newMaxHp),
      workoutXpToday: source == XpAwardSource.workout
          ? workoutXpToday + acceptedAmount
          : workoutXpToday,
      questXpToday: source == XpAwardSource.quest
          ? questXpToday + acceptedAmount
          : questXpToday,
      xpBudgetDate: today,
      processedEventXp: processedEvents,
      updatedAt: now,
    );

    return ProgressionResult(
      user: updated,
      xpAwarded: acceptedAmount,
      leveledUp: leveledUp,
    );
  }

  static ProgressionResult completeWorkout(
    UserModel current, {
    required String eventId,
    required int requestedXp,
    required Map<String, int> masteryPoints,
    required Iterable<String> personalRecordMovementIds,
    required DateTime now,
    required bool countsForStreak,
    int missedScheduledDays = 0,
  }) {
    if (current.processedEventXp.containsKey(eventId)) {
      return ProgressionResult(
        user: current,
        xpAwarded: current.processedEventXp[eventId]!,
        leveledUp: false,
        duplicate: true,
      );
    }

    final awarded = awardXp(
      current,
      requestedXp,
      source: XpAwardSource.workout,
      now: now,
      eventId: eventId,
    );
    final afterXp = awarded.user;
    final vitality = afterXp.getStat(StatType.vitality);
    final hpCost = HpCalculator.exertionCost(awarded.xpAwarded, vitality);
    var hpBeforeCost = current.currentHp;
    final previousWorkout = current.lastWorkoutAt;
    if (previousWorkout != null && !_isSameDay(previousWorkout, now)) {
      hpBeforeCost = HpCalculator.applyRegen(
        hpBeforeCost,
        afterXp.maxHp,
        HpCalculator.dailyRegen(vitality),
      );
    }

    final mastery = Map<String, int>.from(current.masteryXp);
    for (final entry in masteryPoints.entries) {
      mastery[entry.key] = (mastery[entry.key] ?? 0) + entry.value;
    }

    final records = {
      ...current.personalRecordMovementIds,
      ...personalRecordMovementIds,
    }.toList(growable: false);
    final streakUpdate = _updateStreak(
      current,
      now: now,
      countsForStreak: countsForStreak,
      missedScheduledDays: missedScheduledDays,
    );

    final updated = afterXp.copyWith(
      masteryXp: mastery,
      personalRecordMovementIds: records,
      totalWorkoutsCompleted: current.totalWorkoutsCompleted + 1,
      currentHp: awarded.leveledUp
          ? afterXp.maxHp
          : (hpBeforeCost - hpCost).clamp(0, afterXp.maxHp),
      streak: streakUpdate.streak,
      longestStreak: math.max(
        current.longestStreak,
        streakUpdate.streak,
      ),
      streakShields: streakUpdate.shields,
      scheduledCompletions: streakUpdate.scheduledCompletions,
      lastWorkoutAt: now,
      lastStreakWorkoutAt:
          streakUpdate.counted ? now : current.lastStreakWorkoutAt,
      completedScheduledDates: streakUpdate.completedDates,
      updatedAt: now,
    );

    return ProgressionResult(
      user: updated,
      xpAwarded: awarded.xpAwarded,
      leveledUp: awarded.leveledUp,
    );
  }

  static ProgressionResult completeBossVictory(
    UserModel current, {
    required String bossId,
    required int requestedXp,
    required DateTime now,
  }) {
    final eventId = 'boss:$bossId';
    if (current.processedEventXp.containsKey(eventId)) {
      return ProgressionResult(
        user: current,
        xpAwarded: current.processedEventXp[eventId]!,
        leveledUp: false,
        duplicate: true,
      );
    }

    final awarded = awardXp(
      current,
      requestedXp,
      source: XpAwardSource.boss,
      now: now,
      eventId: eventId,
    );
    return ProgressionResult(
      user: awarded.user.copyWith(
        bossBattlesWon: current.bossBattlesWon + 1,
        updatedAt: now,
      ),
      xpAwarded: awarded.xpAwarded,
      leveledUp: awarded.leveledUp,
    );
  }

  static UserModel unlockTitles(
    UserModel current,
    Iterable<String> titles, {
    required DateTime now,
  }) {
    final merged = {...current.unlockedTitles, ...titles}.toList();
    return current.copyWith(
      unlockedTitles: merged,
      title: current.title.isEmpty && merged.isNotEmpty
          ? merged.first
          : current.title,
      updatedAt: now,
    );
  }

  /// Compatibility helper for system-authored grants.
  static UserModel gainXp(
    UserModel current,
    int amount, {
    required DateTime now,
  }) {
    return awardXp(
      current,
      amount,
      source: XpAwardSource.system,
      now: now,
    ).user;
  }

  static int calculateStreak({
    required DateTime? lastWorkout,
    required int currentStreak,
    required DateTime now,
  }) {
    if (currentStreak <= 0 || lastWorkout == null) return 1;
    if (_isSameDay(lastWorkout, now)) return currentStreak;
    final difference = _dateOnly(now).difference(_dateOnly(lastWorkout)).inDays;
    return difference == 1 ? currentStreak + 1 : 1;
  }

  static bool isSameDay(DateTime a, DateTime b) => _isSameDay(a, b);

  static bool isConsecutiveDay(DateTime a, DateTime b) =>
      _dateOnly(b).difference(_dateOnly(a)).inDays == 1;

  static _StreakUpdate _updateStreak(
    UserModel current, {
    required DateTime now,
    required bool countsForStreak,
    required int missedScheduledDays,
  }) {
    final previous = current.lastStreakWorkoutAt;
    if (!countsForStreak || (previous != null && _isSameDay(previous, now))) {
      return _StreakUpdate(
        streak: current.streak,
        shields: current.streakShields,
        scheduledCompletions: current.scheduledCompletions,
        completedDates: current.completedScheduledDates,
        counted: false,
      );
    }

    var shields = current.streakShields;
    late final int streak;
    if (current.streak <= 0 || previous == null) {
      streak = 1;
    } else if (missedScheduledDays <= 0) {
      streak = current.streak + 1;
    } else if (missedScheduledDays <= shields) {
      shields -= missedScheduledDays;
      streak = current.streak + 1;
    } else {
      shields = 0;
      streak = 1;
    }

    final scheduledCompletions = current.scheduledCompletions + 1;
    if (scheduledCompletions % 7 == 0) {
      shields = math.min(3, shields + 1);
    }

    final dates = {
      ...current.completedScheduledDates.map(_dateOnly),
      _dateOnly(now),
    }.toList()
      ..sort();
    return _StreakUpdate(
      streak: streak,
      shields: shields,
      scheduledCompletions: scheduledCompletions,
      completedDates: dates,
      counted: true,
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _StreakUpdate {
  final int streak;
  final int shields;
  final int scheduledCompletions;
  final List<DateTime> completedDates;
  final bool counted;

  const _StreakUpdate({
    required this.streak,
    required this.shields,
    required this.scheduledCompletions,
    required this.completedDates,
    required this.counted,
  });
}

import 'dart:math' as math;

/// Converts a completed training session into deliberately scarce character XP.
///
/// E is the number of exercise families with at least one valid set, S is the
/// total number of valid sets (capped at 32), and completion is measured
/// against all planned sets:
/// `round(min(25, 10 + 4√E + 1.5√min(S, 32)) × completionRate)`.
class WorkoutRewardService {
  WorkoutRewardService._();

  static const int maxSessionXp = 25;
  static const int maxWorkoutXpPerDay = 25;
  static const int maxQuestXpPerDay = 5;
  static const int maxCharacterXpPerDay = maxWorkoutXpPerDay + maxQuestXpPerDay;
  static const double minimumCompletionRate = 0.5;

  static int calculateSessionXp({
    required int exerciseFamilies,
    required int validSets,
    required int plannedSets,
    double? completionRate,
  }) {
    if (exerciseFamilies <= 0 || validSets <= 0 || plannedSets <= 0) {
      return 0;
    }

    final effectiveCompletionRate =
        (completionRate ?? validSets / plannedSets).clamp(0.0, 1.0);
    if (effectiveCompletionRate < minimumCompletionRate) return 0;

    final effort = 10 +
        (4 * math.sqrt(exerciseFamilies)) +
        (1.5 * math.sqrt(math.min(validSets, 32)));
    return (math.min(maxSessionXp, effort) * effectiveCompletionRate).round();
  }

  static int remainingWorkoutBudget(int alreadyEarned) =>
      (maxWorkoutXpPerDay - alreadyEarned).clamp(0, maxWorkoutXpPerDay);

  static int remainingQuestBudget(int alreadyEarned) =>
      (maxQuestXpPerDay - alreadyEarned).clamp(0, maxQuestXpPerDay);
}

import 'dart:math' as math;

/// Exercise-specific progression that does not mutate physiological base stats.
class MasteryService {
  MasteryService._();

  static const int maxRank = 100;

  static int pointsForSession({
    required int validSets,
    required double difficultyMultiplier,
    bool isPersonalRecord = false,
  }) {
    if (validSets <= 0 || difficultyMultiplier <= 0) return 0;
    final personalRecordMultiplier = isPersonalRecord ? 1.2 : 1.0;
    return (5 *
            math.sqrt(validSets) *
            difficultyMultiplier *
            personalRecordMultiplier)
        .round();
  }

  static int pointsForNextRank(int rank) {
    final safeRank = rank.clamp(0, maxRank);
    return 20 + (5 * safeRank);
  }

  static int rankForTotalXp(int totalXp) {
    var remaining = totalXp.clamp(0, 1 << 31);
    var rank = 0;
    while (rank < maxRank) {
      final required = pointsForNextRank(rank);
      if (remaining < required) break;
      remaining -= required;
      rank++;
    }
    return rank;
  }

  static int xpWithinRank(int totalXp) {
    var remaining = totalXp.clamp(0, 1 << 31);
    var rank = 0;
    while (rank < maxRank) {
      final required = pointsForNextRank(rank);
      if (remaining < required) break;
      remaining -= required;
      rank++;
    }
    return rank == maxRank ? 0 : remaining;
  }
}

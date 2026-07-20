import 'dart:math' as math;

/// Character-level XP curve.
///
/// The cost of advancing from level L is `round(100 × L^1.4)`. Cumulative
/// thresholds are derived from that formula so there is no level cap or
/// duplicated lookup table.
class LevelRequirements {
  LevelRequirements._();

  /// XP required within [level] before advancing to the next level.
  static int xpToNextLevel(int level) {
    _validateLevel(level);
    return (100 * math.pow(level, 1.4)).round();
  }

  /// Total lifetime XP required to enter [level].
  static int totalXpForLevel(int level) {
    _validateLevel(level);
    var total = 0;
    for (var current = 1; current < level; current++) {
      total += xpToNextLevel(current);
    }
    return total;
  }

  static bool canLevelUp(int currentLevel, int totalXp) =>
      totalXp >= totalXpForLevel(currentLevel) + xpToNextLevel(currentLevel);

  static int calculateLevel(int totalXp) {
    if (totalXp < 0) {
      throw RangeError.value(totalXp, 'totalXp', 'must not be negative');
    }
    var level = 1;
    var remaining = totalXp;
    while (remaining >= xpToNextLevel(level)) {
      remaining -= xpToNextLevel(level);
      level++;
    }
    return level;
  }

  static double progressToNext(int currentLevel, int currentXp) {
    final needed = xpToNextLevel(currentLevel);
    if (needed <= 0) return 1.0;
    return (currentXp / needed).clamp(0.0, 1.0);
  }

  // Alias for existing provider compatibility
  static double levelProgress(int level, int currentXp) =>
      progressToNext(level, currentXp);

  static void _validateLevel(int level) {
    if (level < 1) {
      throw RangeError.value(level, 'level', 'must be at least 1');
    }
  }
}

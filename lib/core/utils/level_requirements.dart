/// Hunter System level thresholds.
class LevelRequirements {
  LevelRequirements._();

  static const Map<int, int> _thresholds = {
    1: 0,
    2: 100,
    3: 250,
    4: 450,
    5: 700,
    6: 1000,
    7: 1400,
    8: 1900,
    9: 2500,
    10: 3200,
  };

  /// XP required within [level] before advancing to the next level.
  static int xpToNextLevel(int level) {
    final currentThreshold = _thresholds[level] ?? 0;
    final nextThreshold = _thresholds[level + 1];
    return nextThreshold == null
        ? level * 500
        : nextThreshold - currentThreshold;
  }

  static int totalXpForLevel(int level) => _thresholds[level] ?? 0;

  static bool canLevelUp(int currentLevel, int totalXp) =>
      totalXp >= totalXpForLevel(currentLevel) + xpToNextLevel(currentLevel);

  static int calculateLevel(int totalXp) {
    int lvl = 1;
    for (final e in _thresholds.entries) {
      if (totalXp >= e.value) lvl = e.key;
    }
    return lvl;
  }

  static double progressToNext(int currentLevel, int currentXp) {
    final needed = xpToNextLevel(currentLevel);
    if (needed <= 0) return 1.0;
    return (currentXp / needed).clamp(0.0, 1.0);
  }

  // Alias for existing provider compatibility
  static double levelProgress(int level, int currentXp) =>
      progressToNext(level, currentXp);
}

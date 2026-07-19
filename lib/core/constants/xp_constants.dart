class XpConstants {
  XpConstants._();

  /// Base XP per rep for standard difficulty exercise
  static const int baseXpPerSet = 5;

  /// Streak XP bonus
  static double streakMultiplier(int streak) =>
      1.0 + (streak * 0.01).clamp(0.0, 0.5);

  /// Quest completion bonus
  static const double questXpMultiplier = 1.25;
}

class HpCalculator {
  /// Constitution determines max HP
  static int maxHp(int constitution, int level) {
    return 50 + (constitution * 10) + (level * 5);
  }

  /// HP regen per day (for recovery between sessions)
  static int dailyRegen(int constitution, int endurance) {
    return 10 + (constitution * 2) + (endurance ~/ 2);
  }

  /// HP lost during boss battle from exertion
  static int exertionCost(int totalWorkoutXp, int constitution) {
    if (totalWorkoutXp <= 0) return 0;

    final base = totalWorkoutXp ~/ 20;
    final reduction = constitution * 2;
    final maximum = base < 5 ? 5 : base;
    return (base - reduction).clamp(5, maximum);
  }

  /// Calculate HP after applying regen
  static int applyRegen(int currentHp, int maxHp, int regenAmount) {
    return (currentHp + regenAmount).clamp(0, maxHp);
  }

  /// Check if player has enough HP for a workout
  static bool canWorkout(int currentHp) {
    return currentHp >= 10;
  }
}

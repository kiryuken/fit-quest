import '../enums/exercise_type.dart';
import '../enums/stat_type.dart';
import '../constants/xp_constants.dart';

class XpCalculator {
  /// Base XP for one exercise entry
  static int baseXpForExercise({
    required ExerciseType type,
    required int reps,
    double weight = 0.0,
  }) {
    final base = XpConstants.baseXpPerSet.toDouble();
    final diffMult = type.difficultyMultiplier;
    final weightBonus = (weight / 10).clamp(0.0, 3.0);
    return (base * diffMult * (1 + weightBonus)).round();
  }

  /// XP modified by form quality
  static int formModifiedXp(int baseXp, double formQuality) {
    final multiplier = 0.5 + formQuality; // range: 0.5 - 1.5
    return (baseXp * multiplier).round();
  }

  /// XP earned toward a specific stat from exercise
  static int statXpFromExercise({
    required ExerciseType type,
    required StatType stat,
    required int totalExerciseXp,
    required double formQuality,
  }) {
    final weight = type.statWeights[stat] ?? 0.0;
    if (weight <= 0) return 0;
    return (totalExerciseXp * weight * (0.7 + 0.3 * formQuality)).round();
  }

  /// Total workout XP with all bonuses
  static int totalWorkoutXp({
    required List<int> exerciseXpValues,
    int currentStreak = 0,
    bool hasActiveQuest = false,
  }) {
    final base = exerciseXpValues.fold<int>(0, (sum, x) => sum + x);
    final streakBonus = XpConstants.streakMultiplier(currentStreak);
    final questBonus = hasActiveQuest ? XpConstants.questXpMultiplier : 1.0;
    return (base * streakBonus * questBonus).round();
  }

  /// Calculate all stat XP from a list of exercises
  static Map<StatType, int> calculateStatXpDistribution({
    required List<({ExerciseType type, int reps, double weight, double formQuality})> exercises,
  }) {
    final statXp = <StatType, int>{};
    for (final stat in StatType.values) {
      statXp[stat] = 0;
    }
    for (final ex in exercises) {
      final baseXp = baseXpForExercise(
        type: ex.type,
        reps: ex.reps,
        weight: ex.weight,
      );
      final totalXp = formModifiedXp(baseXp, ex.formQuality);
      for (final stat in StatType.values) {
        statXp[stat] = (statXp[stat] ?? 0) +
            statXpFromExercise(
              type: ex.type,
              stat: stat,
              totalExerciseXp: totalXp,
              formQuality: ex.formQuality,
            );
      }
    }
    return statXp;
  }

  /// Calculate XP needed for a stat to increase by one point
  static int xpForNextStatPoint(StatType stat, int currentValue) {
    return (100 * _pow(1.05, currentValue)).round();
  }

  static double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

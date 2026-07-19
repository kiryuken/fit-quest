import '../../core/enums/stat_type.dart';
import '../../core/constants/stat_constants.dart';
import '../../core/utils/xp_calculator.dart';

class StatProgressionService {
  /// Calculate stat gains from accumulated XP
  static Map<StatType, int> calculateStatGains({
    required Map<StatType, int> currentStats,
    required Map<StatType, int> statXpGained,
  }) {
    final gains = <StatType, int>{};
    for (final stat in StatType.values) {
      final xp = statXpGained[stat] ?? 0;
      final current = currentStats[stat] ?? 1;
      final required = XpCalculator.xpForNextStatPoint(stat, current);
      gains[stat] = required > 0 ? xp ~/ required : 0;
    }
    return gains;
  }

  /// Calculate new stat values after applying gains
  static Map<StatType, int> applyStatGains({
    required Map<StatType, int> currentStats,
    required Map<StatType, int> statGains,
  }) {
    final newStats = Map<StatType, int>.from(currentStats);
    for (final entry in statGains.entries) {
      final capped = (newStats[entry.key]! + entry.value)
          .clamp(0, StatConstants.maxStatCap);
      newStats[entry.key] = capped;
    }
    return newStats;
  }

  /// Get stat points earned on level up
  static int statPointsForLevelUp(int newLevel) {
    return StatConstants.statPointsForLevelUp(newLevel);
  }

  /// Check if a stat meets or exceeds a threshold
  static bool meetsRequirement(
      Map<StatType, int> stats, StatType stat, int required) {
    return (stats[stat] ?? 0) >= required;
  }

  /// Get all stat requirements met status
  static Map<StatType, bool> checkAllRequirements(
    Map<StatType, int> stats,
    Map<StatType, int> requirements,
  ) {
    final result = <StatType, bool>{};
    for (final entry in requirements.entries) {
      result[entry.key] = (stats[entry.key] ?? 0) >= entry.value;
    }
    return result;
  }
}

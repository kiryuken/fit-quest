import '../../core/enums/stat_type.dart';
import 'stat_growth_service.dart';

class StatProgressionService {
  /// Character base stats have one source of truth: character level.
  static Map<StatType, double> statsForLevel(int level) =>
      StatGrowthService.statsAtLevel(level);

  /// Check if a stat meets or exceeds a threshold
  static bool meetsRequirement(
      Map<StatType, double> stats, StatType stat, int required) {
    return (stats[stat] ?? 0) >= required;
  }

  /// Get all stat requirements met status
  static Map<StatType, bool> checkAllRequirements(
    Map<StatType, double> stats,
    Map<StatType, int> requirements,
  ) {
    final result = <StatType, bool>{};
    for (final entry in requirements.entries) {
      result[entry.key] = (stats[entry.key] ?? 0) >= entry.value;
    }
    return result;
  }
}

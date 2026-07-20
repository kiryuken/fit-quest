import 'dart:math' as math;

import '../../core/constants/stat_growth_config.dart';
import '../../core/enums/stat_type.dart';

/// Physiological-ceiling model for automatic stat growth from character levels.
///
/// The curve grows quickly for beginners, then slows asymptotically:
/// `ceiling - (ceiling - baseAtLevelOne) * e^(-(level - 1) / tau)`.
class StatGrowthService {
  StatGrowthService._();

  static double baseStatAtLevel(StatType stat, int level) {
    _validateLevel(level);
    final parameters = StatGrowthConfig.forStat(stat);
    final exponent = -(level - 1) / parameters.tau;

    return parameters.ceiling -
        (parameters.ceiling - parameters.baseAtLevelOne) * math.exp(exponent);
  }

  /// Exact base-stat gain for the transition from [level] to `level + 1`.
  static double gainForNextLevel(StatType stat, int level) {
    _validateLevel(level);
    return baseStatAtLevel(stat, level + 1) - baseStatAtLevel(stat, level);
  }

  /// Exact values for every canonical stat at [level].
  static Map<StatType, double> statsAtLevel(int level) {
    _validateLevel(level);
    return {
      for (final stat in StatType.values) stat: baseStatAtLevel(stat, level),
    };
  }

  /// Hive-friendly representation keyed by canonical enum index.
  static Map<int, double> indexedStatsAtLevel(int level) {
    return {
      for (final entry in statsAtLevel(level).entries)
        entry.key.index: entry.value,
    };
  }

  /// Exact cumulative gain across one or more level transitions.
  ///
  /// Summing [gainForNextLevel] keeps that per-level delta as the only source
  /// of truth instead of introducing a lookup table.
  static double gainBetweenLevels(
    StatType stat, {
    required int fromLevel,
    required int toLevel,
  }) {
    _validateLevelRange(fromLevel, toLevel);

    var gain = 0.0;
    for (var level = fromLevel; level < toLevel; level++) {
      gain += gainForNextLevel(stat, level);
    }
    return gain;
  }

  static void _validateLevel(int level) {
    if (level < 1) {
      throw RangeError.value(level, 'level', 'must be at least 1');
    }
  }

  static void _validateLevelRange(int fromLevel, int toLevel) {
    _validateLevel(fromLevel);
    _validateLevel(toLevel);
    if (toLevel < fromLevel) {
      throw ArgumentError.value(
        toLevel,
        'toLevel',
        'must be greater than or equal to fromLevel',
      );
    }
  }
}

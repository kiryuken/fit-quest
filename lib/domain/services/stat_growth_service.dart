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

  /// Whole stat points to persist in the current integer-based Hive model.
  ///
  /// The cumulative curve is rounded at both endpoints. Individual fractional
  /// deltas are deliberately not rounded, otherwise late-level gains would be
  /// lost and the stored progression would plateau too early.
  static int wholePointGainBetweenLevels(
    StatType stat, {
    required int fromLevel,
    required int toLevel,
  }) {
    _validateLevelRange(fromLevel, toLevel);
    final growthAtStart = gainBetweenLevels(
      stat,
      fromLevel: 1,
      toLevel: fromLevel,
    ).round();
    final growthAtEnd = gainBetweenLevels(
      stat,
      fromLevel: 1,
      toLevel: toLevel,
    ).round();
    return growthAtEnd - growthAtStart;
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

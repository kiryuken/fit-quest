import '../enums/stat_type.dart';

/// Tunable parameters for one stat's physiological growth curve.
class StatGrowthParameters {
  final double baseAtLevelOne;
  final double ceiling;
  final double tau;

  const StatGrowthParameters({
    required this.baseAtLevelOne,
    required this.ceiling,
    required this.tau,
  });
}

/// Single source of truth for automatic base-stat growth from character levels.
class StatGrowthConfig {
  StatGrowthConfig._();

  static const defaultParameters = StatGrowthParameters(
    baseAtLevelOne: 10,
    ceiling: 50,
    tau: 26,
  );

  /// Entries are explicit so each stat can be tuned independently later.
  static const parametersByStat = <StatType, StatGrowthParameters>{
    StatType.strength: defaultParameters,
    StatType.agility: defaultParameters,
    StatType.endurance: defaultParameters,
    StatType.dexterity: defaultParameters,
    StatType.constitution: defaultParameters,
    StatType.intelligence: defaultParameters,
  };

  static StatGrowthParameters forStat(StatType stat) => parametersByStat[stat]!;
}

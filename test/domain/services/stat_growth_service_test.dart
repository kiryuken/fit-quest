import 'package:fitquest_rpg/core/constants/stat_growth_config.dart';
import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/domain/services/stat_growth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatGrowthService', () {
    const referenceValues = <int, double>{
      1: 10.00,
      5: 15.70,
      10: 21.70,
      15: 26.65,
      20: 30.74,
      25: 34.11,
      30: 36.89,
      35: 39.18,
      40: 41.07,
      50: 43.92,
      60: 45.86,
      70: 47.18,
      80: 48.08,
      90: 48.70,
      100: 49.11,
    };

    test('matches the physiological-ceiling reference table', () {
      for (final stat in StatType.values) {
        for (final entry in referenceValues.entries) {
          expect(
            StatGrowthService.baseStatAtLevel(stat, entry.key),
            closeTo(entry.value, 0.1),
            reason: '${stat.name} at level ${entry.key}',
          );
        }
      }
    });

    test('defines independently tunable parameters for every model stat', () {
      expect(
        StatGrowthConfig.parametersByStat.keys.toSet(),
        StatType.values.toSet(),
      );
    });

    test('derives each level gain from adjacent curve values', () {
      for (final stat in StatType.values) {
        for (final level in const [1, 5, 20, 50, 99]) {
          final expected = StatGrowthService.baseStatAtLevel(stat, level + 1) -
              StatGrowthService.baseStatAtLevel(stat, level);

          expect(
            StatGrowthService.gainForNextLevel(stat, level),
            closeTo(expected, 0.000000001),
          );
        }
      }
    });

    test('slows toward the ceiling without crossing it', () {
      const stat = StatType.strength;
      final beginnerGain = StatGrowthService.gainForNextLevel(stat, 1);
      final advancedGain = StatGrowthService.gainForNextLevel(stat, 50);
      final eliteGain = StatGrowthService.gainForNextLevel(stat, 99);

      expect(beginnerGain, greaterThan(advancedGain));
      expect(advancedGain, greaterThan(eliteGain));
      expect(
        StatGrowthService.baseStatAtLevel(stat, 100),
        lessThan(StatGrowthConfig.forStat(stat).ceiling),
      );
    });

    test('rejects invalid or descending level ranges', () {
      expect(
        () => StatGrowthService.baseStatAtLevel(StatType.strength, 0),
        throwsRangeError,
      );
      expect(
        () => StatGrowthService.gainBetweenLevels(
          StatType.strength,
          fromLevel: 5,
          toLevel: 4,
        ),
        throwsArgumentError,
      );
    });
  });
}

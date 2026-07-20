import 'package:fitquest_rpg/core/utils/level_requirements.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelRequirements', () {
    test('returns XP required within each level', () {
      expect(LevelRequirements.xpToNextLevel(1), 100);
      expect(LevelRequirements.xpToNextLevel(2), 264);
      expect(LevelRequirements.xpToNextLevel(3), 466);
    });

    test('calculates progress from in-level XP', () {
      expect(
        LevelRequirements.levelProgress(2, 50),
        closeTo(50 / 264, 0.000001),
      );
    });

    test('compares total XP against the cumulative next threshold', () {
      expect(LevelRequirements.canLevelUp(2, 363), isFalse);
      expect(LevelRequirements.canLevelUp(2, 364), isTrue);
    });

    test('six-month target remains level 6 with 642 in-level XP', () {
      expect(LevelRequirements.calculateLevel(3120), 6);
      expect(3120 - LevelRequirements.totalXpForLevel(6), 642);
      expect(LevelRequirements.xpToNextLevel(6), 1229);
    });
  });
}

import 'package:fitquest_rpg/core/utils/level_requirements.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelRequirements', () {
    test('returns XP required within each level', () {
      expect(LevelRequirements.xpToNextLevel(1), 100);
      expect(LevelRequirements.xpToNextLevel(2), 150);
      expect(LevelRequirements.xpToNextLevel(3), 200);
    });

    test('calculates progress from in-level XP', () {
      expect(
        LevelRequirements.levelProgress(2, 50),
        closeTo(1 / 3, 0.000001),
      );
    });

    test('compares total XP against the cumulative next threshold', () {
      expect(LevelRequirements.canLevelUp(2, 249), isFalse);
      expect(LevelRequirements.canLevelUp(2, 250), isTrue);
    });
  });
}

import 'package:fitquest_rpg/domain/services/hp_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HpCalculator.exertionCost', () {
    test('does not throw for normal workouts below 100 XP', () {
      expect(HpCalculator.exertionCost(20, 1), 5);
      expect(HpCalculator.exertionCost(35, 1), 5);
      expect(HpCalculator.exertionCost(99, 1), 5);
    });

    test('applies vitality reduction within the valid range', () {
      expect(HpCalculator.exertionCost(200, 1), 8);
      expect(HpCalculator.exertionCost(200, 3), 5);
    });

    test('charges no exertion for zero XP', () {
      expect(HpCalculator.exertionCost(0, 1), 0);
    });
  });
}

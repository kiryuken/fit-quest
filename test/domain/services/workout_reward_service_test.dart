import 'package:fitquest_rpg/domain/services/workout_reward_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutRewardService', () {
    test('normal Push Day earns 23 XP as one complete session', () {
      expect(
        WorkoutRewardService.calculateSessionXp(
          exerciseFamilies: 2,
          validSets: 24,
          plannedSets: 24,
        ),
        23,
      );
    });

    test('large Pull Day reaches but never exceeds the 25 XP cap', () {
      expect(
        WorkoutRewardService.calculateSessionXp(
          exerciseFamilies: 3,
          validSets: 32,
          plannedSets: 32,
        ),
        25,
      );
      expect(
        WorkoutRewardService.calculateSessionXp(
          exerciseFamilies: 50,
          validSets: 500,
          plannedSets: 500,
        ),
        25,
      );
    });

    test('completion below 50 percent receives no session XP', () {
      expect(
        WorkoutRewardService.calculateSessionXp(
          exerciseFamilies: 2,
          validSets: 11,
          plannedSets: 24,
        ),
        0,
      );
      expect(
        WorkoutRewardService.calculateSessionXp(
          exerciseFamilies: 2,
          validSets: 12,
          plannedSets: 24,
        ),
        10,
      );
    });

    test('remaining daily budgets cannot become negative', () {
      expect(WorkoutRewardService.remainingWorkoutBudget(0), 25);
      expect(WorkoutRewardService.remainingWorkoutBudget(25), 0);
      expect(WorkoutRewardService.remainingWorkoutBudget(999), 0);
      expect(WorkoutRewardService.remainingQuestBudget(3), 2);
      expect(WorkoutRewardService.remainingQuestBudget(999), 0);
    });
  });
}

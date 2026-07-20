import 'package:fitquest_rpg/core/data/workout_plan_catalog.dart';
import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/utils/level_requirements.dart';
import 'package:fitquest_rpg/domain/services/stat_growth_service.dart';
import 'package:fitquest_rpg/domain/services/workout_reward_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('26 weeks of the normal Legs Once plan remains non-anomalous', () {
    final plan = WorkoutPlanCatalog.create(
      presetId: WorkoutPlanCatalog.legsOnce,
      fitnessLevel: 'Intermediate',
      now: DateTime(2026, 7, 20),
    );
    var weeklyWorkoutXp = 0;
    for (final day in plan.days.where((day) => day.countsForStreak)) {
      final allPlannedSets = day.exercises
          .expand((exercise) => exercise.variations)
          .fold<int>(0, (total, variation) => total + variation.targetSets);
      final validExercises =
          day.exercises.where((exercise) => !exercise.isOptional).toList();
      final validSets = validExercises
          .expand((exercise) => exercise.variations)
          .fold<int>(0, (total, variation) => total + variation.targetSets);
      weeklyWorkoutXp += WorkoutRewardService.calculateSessionXp(
        exerciseFamilies: validExercises.length,
        validSets: validSets,
        plannedSets: allPlannedSets,
      );
    }

    final workoutOnlyXp = weeklyWorkoutXp * 26;
    const perfectQuestBonus = 5 * 5 * 26;
    final maximumExpectedXp = workoutOnlyXp + perfectQuestBonus;

    expect(weeklyWorkoutXp, 117);
    expect(workoutOnlyXp, 3042);
    expect(LevelRequirements.calculateLevel(workoutOnlyXp), 6);
    expect(maximumExpectedXp, 3692);
    expect(LevelRequirements.calculateLevel(maximumExpectedXp), 6);
    expect(
      StatGrowthService.baseStatAtLevel(StatType.strength, 6),
      closeTo(16.99, 0.1),
    );
    expect(
      StatGrowthService.baseStatAtLevel(StatType.strength, 6),
      lessThan(StatGrowthService.baseStatAtLevel(StatType.strength, 10)),
    );
  });
}

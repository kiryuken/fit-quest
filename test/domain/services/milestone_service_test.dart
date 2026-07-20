import 'package:fitquest_rpg/core/data/workout_plan_catalog.dart';
import 'package:fitquest_rpg/core/enums/exercise_type.dart';
import 'package:fitquest_rpg/data/models/achievement_state.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/domain/services/milestone_service.dart';
import 'package:fitquest_rpg/domain/services/weekly_plan_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final plan = WorkoutPlanCatalog.create(
    presetId: WorkoutPlanCatalog.legsOnce,
    fitnessLevel: 'Intermediate',
    now: DateTime(2026, 1, 1),
  );

  test('first valid committed workout unlocks Awakening only once eligible',
      () {
    final user = _user(createdAt: DateTime(2026, 7, 20));
    final evaluation = MilestoneService.evaluate(
      user: user,
      plan: plan,
      workouts: [_workout(DateTime(2026, 7, 20))],
      now: DateTime(2026, 7, 20),
    );

    expect(evaluation.eligibleAchievementIds,
        contains(AchievementCatalog.awakening));
    expect(evaluation.titles, contains('Awakened'));
  });

  test('four-week milestone uses scheduled adherence, not raw workout count',
      () {
    final created = DateTime(2026, 6, 1);
    final now = DateTime(2026, 6, 28);
    final required = WeeklyPlanService.requiredDates(
      plan: plan,
      from: created,
      through: now,
    );
    final completed =
        required.take((required.length * 0.75).ceil()).map(_workout).toList();

    final evaluation = MilestoneService.evaluate(
      user: _user(createdAt: created),
      plan: plan,
      workouts: completed,
      now: now,
    );

    expect(evaluation.adherence, greaterThanOrEqualTo(0.75));
    expect(
      evaluation.eligibleAchievementIds,
      contains(AchievementCatalog.habitForged),
    );
  });

  test('twelve-week milestone additionally requires two improved families', () {
    final created = DateTime(2026, 1, 5);
    final now = created.add(const Duration(days: 83));
    final required = WeeklyPlanService.requiredDates(
      plan: plan,
      from: created,
      through: now,
    );
    final user = _user(
      createdAt: created,
      records: const ['push_up', 'pull_up'],
    );

    final evaluation = MilestoneService.evaluate(
      user: user,
      plan: plan,
      workouts: required.map(_workout),
      now: now,
    );

    expect(
      evaluation.eligibleAchievementIds,
      contains(AchievementCatalog.foundationBuilt),
    );
  });
}

UserModel _user({
  required DateTime createdAt,
  List<String> records = const [],
}) {
  return UserModel(
    id: 'user',
    name: 'Tester',
    personalRecordMovementIds: records,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

WorkoutModel _workout(DateTime date) {
  return WorkoutModel(
    id: 'workout-${date.toIso8601String()}',
    date: date,
    createdAt: date,
    completed: true,
    processingStateIndex: WorkoutProcessingState.committed.index,
    completionRate: 1,
    countsForStreak: true,
    exercises: [
      ExerciseRecord(
        id: 'exercise-${date.toIso8601String()}',
        exerciseTypeIndex: ExerciseType.pushUp.index,
        sets: 1,
        reps: 10,
      ),
    ],
  );
}
